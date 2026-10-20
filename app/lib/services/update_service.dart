import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    this.downloadUrl,
    this.releasePageUrl,
    this.sizeBytes,
  });

  /// Версия из манифеста как есть (например `v5.9.0` или `5.9.0`).
  final String version;

  /// Примечания к релизу (тело GitHub-релиза или поле `notes` манифеста).
  final String notes;

  /// Прямая ссылка на APK (может отсутствовать — тогда только страница релиза).
  final String? downloadUrl;

  /// Страница релиза в браузере (html_url у GitHub, `url` у простого манифеста).
  final String? releasePageUrl;

  /// Размер APK в байтах (если известен).
  final int? sizeBytes;

  /// Имя файла, под которым APK сохраняется при скачивании.
  String get suggestedFileName {
    final cleanVersion = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return 'LingoTune-v$cleanVersion.apk';
  }
}

/// Проверка и скачивание обновлений приложения.
///
/// Источник по умолчанию — GitHub Releases репозитория проекта
/// (`/releases/latest`). Понимает и простой JSON-манифест
/// `{"version": "...", "notes": "...", "downloadUrl": "..."}` — адрес можно
/// переопределить ключом настроек `updateManifestUrl`. Пока репозиторий
/// приватный (GitHub отвечает 404 анонимно), проверка тихо завершается
/// «нет обновлений» — механизм заработает без правок приложения, как только
/// появятся публичные релизы или будет указан другой манифест.
class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const String defaultManifestUrl =
      'https://api.github.com/repos/summonss7/LingoTune/releases/latest';

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

  Future<Uri> _manifestUri() async {
    final custom = await getCustomManifestUrl();
    if (custom != null) {
      final parsed = Uri.tryParse(custom);
      if (parsed != null && (parsed.isScheme('http') || parsed.isScheme('https'))) {
        return parsed;
      }
    }
    return Uri.parse(defaultManifestUrl);
  }

  /// Пользовательский адрес манифеста (вариант «б» из пожелания: любой
  /// источник — JSON `{"version","downloadUrl",...}` или GitHub API).
  /// `null` — адрес не задан, используется [defaultManifestUrl].
  static Future<String?> getCustomManifestUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_prefManifestUrl);
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    return null;
  }

  /// Сохраняет пользовательский адрес манифеста; `null`/пустая строка —
  /// сброс на источник по умолчанию (GitHub Releases).
  static Future<void> setCustomManifestUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    final value = url?.trim() ?? '';
    if (value.isEmpty) {
      await prefs.remove(_prefManifestUrl);
    } else {
      await prefs.setString(_prefManifestUrl, value);
    }
  }

  /// Проверяет манифест; возвращает [AppUpdate], только если там версия новее
  /// текущей ([AppInfo.version]). Любая недоступность источника (нет сети,
  /// приватный репозиторий, кривой JSON) — это `null`, а не ошибка: тихий
  /// фоновый автоЧек не должен показывать пользователю «ошибку» за то,
  /// что хозяин ещё не выложил релиз.
  Future<AppUpdate?> checkForUpdate() async {
    final uri = await _manifestUri();
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
      debugPrint('✗ UpdateService: manifest parse error: $e');
      return null;
    }
    if (data is! Map) return null;

    final update = _parseManifest(data);
    if (update == null) return null;

    return isNewer(update.version, AppInfo.version) ? update : null;
  }

  /// GitHub-релиз или простой манифест — единая модель.
  static AppUpdate? _parseManifest(Map<dynamic, dynamic> data) {
    if (data.containsKey('tag_name') || data.containsKey('assets')) {
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

  /// Скачивает APK в каталог приложения (updates/). Возвращает путь к файлу
  /// или `null` при ошибке/отмене. [onProgress] получает байты получено/всего
  /// (всего может быть неизвестен — тогда 0).
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

      debugPrint('✓ UpdateService: downloaded $filePath ($received bytes)');
      return filePath;
    } catch (e) {
      debugPrint('✗ UpdateService: download error: $e');
      return null;
    }
  }

  /// Просит прервать текущее скачивание (кнопка «Отмена» в диалоге).
  void cancelDownload() {
    _cancelRequested = true;
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
