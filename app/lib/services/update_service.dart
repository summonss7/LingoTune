import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_info.dart';

/// Описание доступного обновления (нормализовано из манифеста любого формата).
@immutable
class AppUpdate {
  const AppUpdate({
    required this.version,
    required this.notes,
    this.versionCode,
    this.downloadUrl,
    this.releasePageUrl,
    this.sizeBytes,
    this.sha256,
  });

  /// Версия из манифеста как есть (например `v5.9.0`, `5.9.0` или
  /// `versionName` манифеста Aila).
  final String version;

  /// Примечания к релизу (поле `notes` манифеста или тело GitHub-релиза).
  final String notes;

  /// Целочисленный номер сборки (versionCode манифеста Aila). Когда он есть,
  /// сравнение идёт по нему — строгий порядок сборок Android.
  final int? versionCode;

  /// Прямая ссылка на APK (может отсутствовать — тогда только страница релиза).
  final String? downloadUrl;

  /// Страница релиза в браузере (html_url у GitHub, `url` у простого манифеста).
  final String? releasePageUrl;

  /// Размер APK в байтах (если известен).
  final int? sizeBytes;

  /// Ожидаемый sha256 APK из манифеста (сверяется после скачивания).
  final String? sha256;

  /// Имя файла, под которым APK сохраняется при скачивании.
  String get suggestedFileName {
    final cleanVersion = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return 'LingoTune-v$cleanVersion.apk';
  }
}

/// Итог проверки обновлений — три состояния вместо «null обо всём»:
/// ручная проверка должна честно отличать «актуальна» от «не удалось проверить».
enum UpdateCheckStatus { updateAvailable, upToDate, sourceUnavailable }

@immutable
class UpdateCheckResult {
  const UpdateCheckResult(this.status, [this.update]);

  final UpdateCheckStatus status;

  /// Доступное обновление; не `null` только при [UpdateCheckStatus.updateAvailable].
  final AppUpdate? update;
}

/// Проверка и скачивание обновлений приложения.
///
/// Источник по умолчанию — **центр обновлений Aila** (семейный канал,
/// манифест v2: `versionName`/`versionCode`/`notes`/`assets[].sha256`,
/// см. D:\Scheduler\UPDATES-SYSTEM.md). Если канал недоступен (нет сети,
/// сервер спит, кривой JSON) — автоматический резерв: GitHub Releases
/// репозитория. Ответившие источники авторитетны: если манифест прочитан,
/// его вердикт («есть обновление» или «у вас последняя версия») финален,
/// резерв на «нет обновления» не переключается.
///
/// Настройка «Источник обновлений» (`updateManifestUrl`) сохранена: ручной
/// URL проверяется первым и приоритетнее дефолта; при его недоступности
/// срабатывает обычная цепочка Aila → GitHub. Любая недоступность всех
/// источников — это [UpdateCheckStatus.sourceUnavailable], а не ошибка:
/// тихий фоновый автоЧек не должен показывать пользователю «ошибку» за то,
/// что сервер обновлений временно спит.
class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Семейный канал Aila — источник правды о версиях (манифест v2).
  static const String ailaManifestUrl =
      'https://aila.skillcoin.pp.ua/updates/lingotune/manifest.json';

  /// Резерв на случай недоступности Aila (приватный репозиторий отвечает
  /// 404 анонимно — тогда проверка честно говорит «не удалось проверить»).
  static const String githubReleasesUrl =
      'https://api.github.com/repos/summonss7/LingoTune/releases/latest';

  @Deprecated('Источник по умолчанию — центр Aila (ailaManifestUrl), '
      'GitHub — резерв (githubReleasesUrl); карточка lingotune-006')
  static const String defaultManifestUrl = ailaManifestUrl;

  static const String _prefManifestUrl = 'updateManifestUrl';
  static const String _prefLastCheckMs = 'lastUpdateCheckMs';

  /// Как часто автоматическая проверка повторяется при запусках приложения.
  static const Duration autoCheckInterval = Duration(hours: 24);

  final http.Client _client;

  bool _cancelRequested = false;

  /// Прошло ли достаточно времени с последней автоматической проверки.
  static Future<bool> autoCheckDue() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_prefLastCheckMs) ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - last;
    return elapsed >= autoCheckInterval.inMilliseconds;
  }

  /// Отмечает автоматическую проверку выполненной (ставит текущее время).
  static Future<void> markAutoCheckDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _prefLastCheckMs, DateTime.now().millisecondsSinceEpoch);
  }

  /// Пользовательский адрес манифеста (вариант «б» из пожелания: любой
  /// источник — JSON `{"version","downloadUrl",...}`, манифест v2 или GitHub
  /// API). `null` — адрес не задан, используется цепочка по умолчанию.
  static Future<String?> getCustomManifestUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_prefManifestUrl);
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    return null;
  }

  /// Сохраняет пользовательский адрес манифеста; `null`/пустая строка —
  /// сброс на источник по умолчанию (центр Aila, GitHub — резерв).
  static Future<void> setCustomManifestUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    final value = url?.trim() ?? '';
    if (value.isEmpty) {
      await prefs.remove(_prefManifestUrl);
    } else {
      await prefs.setString(_prefManifestUrl, value);
    }
  }

  /// Проверяет источники по цепочке «ручной URL → Aila → GitHub» и возвращает
  /// [UpdateCheckResult]. Первый ОТВЕТИВШИЙ источник решает: новее —
  /// [UpdateCheckStatus.updateAvailable] с описанием, не новее —
  /// [UpdateCheckStatus.upToDate]. Ответили ошибкой все —
  /// [UpdateCheckStatus.sourceUnavailable] (не исключение: автоЧек тихий).
  Future<UpdateCheckResult> checkForUpdate() async {
    final custom = await getCustomManifestUrl();
    final customUri = _parseHttpUri(custom);
    final urls = <Uri>[
      if (customUri != null) customUri,
      Uri.parse(ailaManifestUrl),
      Uri.parse(githubReleasesUrl),
    ];

    var anyResponded = false;
    for (var i = 0; i < urls.length; i++) {
      final uri = urls[i];
      // Ручной URL может совпадать с дефолтным — не дёргаем дважды.
      final seen = urls.sublist(0, i).map((u) => u.toString());
      if (seen.contains(uri.toString())) continue;

      final data = await _fetchManifest(uri);
      if (data == null) continue; // источник недоступен — идём к резерву
      anyResponded = true;

      final update = _parseManifest(data);
      if (update == null) continue; // нечитаемый формат — тоже «не ответил»

      return isNewerThanLocal(update)
          ? UpdateCheckResult(UpdateCheckStatus.updateAvailable, update)
          : const UpdateCheckResult(UpdateCheckStatus.upToDate);
    }

    if (!anyResponded) {
      debugPrint('ℹ UpdateService: все источники обновлений недоступны');
    }
    return const UpdateCheckResult(UpdateCheckStatus.sourceUnavailable);
  }

  static Uri? _parseHttpUri(String? raw) {
    if (raw == null) return null;
    final parsed = Uri.tryParse(raw);
    if (parsed != null &&
        (parsed.isScheme('http') || parsed.isScheme('https'))) {
      return parsed;
    }
    return null;
  }

  /// GET + декод JSON; `null` — любая недоступность (нет сети, таймаут,
  /// не-200, битый JSON, не-объект).
  Future<Map<dynamic, dynamic>?> _fetchManifest(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: const {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint('ℹ UpdateService: manifest ${uri} → HTTP ${response.statusCode}');
        return null;
      }

      final Object? data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        debugPrint('✗ UpdateService: manifest parse error (${uri}): $e');
        return null;
      }
      if (data is! Map) return null;
      return data;
    } catch (e) {
      debugPrint('ℹ UpdateService: manifest unreachable (${uri}): $e');
      return null;
    }
  }

  /// Манифест Aila v2, GitHub-релиз или простой манифест — единая модель.
  static AppUpdate? _parseManifest(Map<dynamic, dynamic> data) {
    if (data.containsKey('versionName') || data.containsKey('versionCode')) {
      // Манифест v2 центра обновлений Aila (UPDATES-SYSTEM.md §4).
      final versionName = (data['versionName'] as String?)?.trim() ?? '';
      final rawCode = data['versionCode'];
      final code = rawCode is int ? rawCode : int.tryParse('$rawCode');
      if (versionName.isEmpty && code == null) return null;

      // Из assets клиент сам выбирает свой артефакт (правило центра):
      // LingoTune — универсальный APK, при нескольких берём release-сборку.
      String? apkUrl;
      int? apkSize;
      String? sha256;
      final assets = data['assets'];
      if (assets is List) {
        Map<dynamic, dynamic>? best;
        for (final asset in assets) {
          if (asset is! Map) continue;
          final name = (asset['name'] as String?)?.toLowerCase() ?? '';
          final url = (asset['url'] as String?)?.toLowerCase() ?? '';
          if (!name.endsWith('.apk') && !url.endsWith('.apk')) continue;
          final kind = (asset['kind'] as String?)?.toLowerCase() ?? '';
          final bestKind =
              best == null ? '' : (best['kind'] as String?)?.toLowerCase() ?? '';
          if (best == null || (kind == 'release' && bestKind != 'release')) {
            best = asset;
          }
        }
        if (best != null) {
          apkUrl = best['url'] as String?;
          final size = best['size'];
          if (size is int) apkSize = size;
          sha256 = (best['sha256'] as String?)?.trim();
          if (sha256 != null && sha256.isEmpty) sha256 = null;
        }
        // Нет APK-asset (например, web-релиз) — манифест бесполезен этому
        // клиенту: проверка уходит в резерв, а не предлагает пустое обновление.
        if (apkUrl == null || apkUrl.isEmpty) return null;
      }

      return AppUpdate(
        version: versionName,
        notes: (data['notes'] as String?) ?? '',
        versionCode: code,
        downloadUrl: apkUrl,
        sizeBytes: apkSize,
        sha256: sha256,
      );
    }

    if (data.containsKey('tag_name')) {
      // GitHub Releases: /releases/latest
      final tag = (data['tag_name'] as String?)?.trim() ?? '';
      if (tag.isEmpty) return null;

      String? apkUrl;
      int? apkSize;
      final assets = data['assets'];
      if (assets is List) {
        for (final asset in assets) {
          if (asset is! Map) continue;
          final name = (asset['name'] as String?)?.toLowerCase() ?? '';
          if (name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            final size = asset['size'];
            if (size is int) apkSize = size;
            break;
          }
        }
      }

      return AppUpdate(
        version: tag,
        notes: (data['body'] as String?) ?? '',
        downloadUrl: apkUrl,
        releasePageUrl: data['html_url'] as String?,
        sizeBytes: apkSize,
      );
    }

    if (data.containsKey('version')) {
      // Простой JSON-манифест: version / notes / downloadUrl / size / url.
      final version = (data['version'] as String?)?.trim() ?? '';
      if (version.isEmpty) return null;
      final size = data['size'];
      return AppUpdate(
        version: version,
        notes: (data['notes'] as String?) ??
            (data['body'] as String?) ??
            '',
        downloadUrl: (data['downloadUrl'] as String?) ??
            (data['apkUrl'] as String?),
        releasePageUrl:
            (data['url'] as String?) ?? (data['releasePageUrl'] as String?),
        sizeBytes: size is int ? size : null,
      );
    }

    return null;
  }

  /// Скачивает APK в каталог приложения (updates/), сверяет sha256 (если
  /// манифест его сообщил) и возвращает путь к файлу или `null` при
  /// ошибке/отмене/несовпадении хэша. [onProgress] получает байты
  /// получено/всего (всего может быть неизвестен — тогда 0).
  Future<String?> downloadUpdate(
    AppUpdate update, {
    void Function(int received, int total)? onProgress,
  }) async {
    final url = update.downloadUrl;
    if (url == null || url.isEmpty) return null;

    _cancelRequested = false;
    try {
      final dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final updatesDir = Directory('${dir.path}/updates');
      if (!await updatesDir.exists()) {
        await updatesDir.create(recursive: true);
      }
      final filePath =
          '${updatesDir.path}/${update.suggestedFileName}';

      final request = http.Request('GET', Uri.parse(url));
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        debugPrint('✗ UpdateService: download failed HTTP ${response.statusCode}');
        return null;
      }

      final total = response.contentLength ?? 0;
      var received = 0;
      final sink = File(filePath).openWrite();
      try {
        await for (final chunk in response.stream) {
          if (_cancelRequested) {
            await sink.close();
            try {
              final stale = File(filePath);
              if (await stale.exists()) {
                await stale.delete();
              }
            } catch (e) {
              debugPrint('ℹ UpdateService: cleanup after cancel failed: $e');
            }
            return null;
          }
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(received, total);
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      // Целостность: sha256 обязателен в манифесте v2 (UPDATES-SYSTEM.md §5);
      // старые источники без хэша пропускают сверку.
      final expected = update.sha256;
      if (expected != null && expected.isNotEmpty) {
        final actual = await _sha256OfFile(File(filePath));
        if (actual.toUpperCase() != expected.toUpperCase()) {
          debugPrint('✗ UpdateService: sha256 mismatch — файл повреждён, '
              'ожидался ${expected.substring(0, 12)}…, получен '
              '${actual.substring(0, 12)}…');
          try {
            await File(filePath).delete();
          } catch (e) {
            debugPrint('ℹ UpdateService: cleanup after mismatch failed: $e');
          }
          return null;
        }
        debugPrint('✓ UpdateService: sha256 verified ($received bytes)');
      }

      debugPrint('✓ UpdateService: downloaded $filePath ($received bytes)');
      return filePath;
    } catch (e) {
      debugPrint('✗ UpdateService: download error: $e');
      return null;
    }
  }

  static Future<String> _sha256OfFile(File file) async {
    final digest = await crypto.sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// Просит прервать текущее скачивание (кнопка «Отмена» в диалоге).
  void cancelDownload() {
    _cancelRequested = true;
  }

  /// `true`, если `candidate` строго новее установленной версии:
  /// при наличии versionCode (манифест v2) — по нему, иначе по строке версии.
  static bool isNewerThanLocal(AppUpdate candidate) {
    final code = candidate.versionCode;
    if (code != null) {
      final localCode = int.tryParse(AppInfo.versionCode);
      if (localCode != null) return code > localCode;
    }
    return isNewer(candidate.version, AppInfo.version);
  }

  /// `true`, если `candidate` строго новее `current`.
  static bool isNewer(String candidate, String current) =>
      compareVersions(candidate, current) > 0;

  /// Побайтово-числовое сравнение семвер-строк: `5.10.0 > 5.9.12 > 5.9 > v5.9.0-beta`.
  /// Терпит префикс `v`, суффиксы пререлиза/сборки и неполные номера.
  static int compareVersions(String a, String b) {
    final pa = _parseParts(a);
    final pb = _parseParts(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }

  static List<int> _parseParts(String version) {
    var core = version.trim().toLowerCase();
    if (core.startsWith('v')) core = core.substring(1);
    // Отрезаем пререлиз/метаданные: 5.9.0-beta.1+build → 5.9.0
    core = core.split(RegExp('[-+]')).first;
    return core
        .split('.')
        .map((part) => int.tryParse(RegExp(r'\d+').stringMatch(part) ?? '') ?? 0)
        .toList();
  }
}
