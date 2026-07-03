import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart' show InputStream;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tts_catalog.dart';

/// Статус модели в [TtsModelManager].
enum TtsModelStatus {
  /// Модель не установлена и не скачивается.
  absent,

  /// Идёт распаковка bundled-модели из ассета.
  extractingBundle,

  /// Идёт скачивание (только для не-bundled).
  downloading,

  /// Скачано, идёт распаковка.
  extracting,

  /// Модель готова к использованию.
  ready,

  /// Ошибка при последней операции.
  error,
}

/// Менеджер офлайн-TTS моделей: установка / удаление / статус / распаковка
/// bundled-ассетов / докачка по сети.
///
/// Хранение: `<app-docs>/tts/<locale>/` с файлами:
///   - model.onnx
///   - tokens.txt
///   - espeak-ng-data/...
/// Папка назначения НЕ содержит voice-подпапку (she bangs верхний уровень
/// tar-архива): например, `vits-piper-ru_RU-irina-medium/model.onnx` из архива
/// кладётся как `<docs>/tts/ru_RU/model.onnx`.
///
/// [ChangeNotifier] — UI (VoicePackagesScreen) подписывается на обновления
/// статуса и прогресса.
class TtsModelManager extends ChangeNotifier {
  TtsModelManager._();
  static final TtsModelManager instance = TtsModelManager._();

  // --- State per language ---
  final Map<String, TtsModelStatus> _status = {};
  final Map<String, double> _progress = {}; // 0.0..1.0 (download/extract)
  final Map<String, String?> _errors = {}; // last error message
  // Активные операции, чтобы не запускать две одновременно для одного языка.
  final Set<String> _inFlight = {};

  TtsModelStatus statusOf(String languageCode) =>
      _status[languageCode.toLowerCase()] ?? TtsModelStatus.absent;
  double progressOf(String languageCode) =>
      _progress[languageCode.toLowerCase()] ?? 0.0;
  String? errorOf(String languageCode) =>
      _errors[languageCode.toLowerCase()];

  /// Корневая папка всех моделей: `<app-docs>/tts/`.
  Future<Directory> _rootDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'tts'));
  }

  /// Папка конкретной модели: `<app-docs>/tts/<locale>/`.
  Future<Directory> modelDir(String localeCode) async {
    final root = await _rootDir();
    return Directory(p.join(root.path, localeCode));
  }

  /// Полный путь к model.onnx (или null если не установлен).
  Future<File?> modelFile(String languageCode) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null) return null;
    final dir = await modelDir(voice.localeCode);
    final f = File(p.join(dir.path, 'model.onnx'));
    return await f.exists() ? f : null;
  }

  /// Установлена ли модель для языка (есть model.onnx).
  Future<bool> isInstalled(String languageCode) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null) return false;
    final dir = await modelDir(voice.localeCode);
    final model = File(p.join(dir.path, 'model.onnx'));
    final tokens = File(p.join(dir.path, 'tokens.txt'));
    return await model.exists() && await tokens.exists();
  }

  /// Полный путь к файлам модели (для [OfflineTtsEngine]).
  /// Возвращает null если модель не установлена.
  Future<({String dir, String model, String tokens, String dataDir})?>
  modelPaths(String languageCode) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null) return null;
    final dir = await modelDir(voice.localeCode);
    final model = File(p.join(dir.path, 'model.onnx'));
    final tokens = File(p.join(dir.path, 'tokens.txt'));
    final dataDir = Directory(p.join(dir.path, 'espeak-ng-data'));
    if (!await model.exists() || !await tokens.exists()) return null;
    return (
      dir: dir.path,
      model: model.path,
      tokens: tokens.path,
      dataDir: dataDir.path,
    );
  }

  // -------------------------------------------------------------------
  // Установка
  // -------------------------------------------------------------------

  /// Гарантирует что bundled-модель (ru) установлена. Если уже установлена —
  /// no-op. Иначе распаковывает из ассета. Безопасно вызывать повторно.
  /// Возвращает true если после вызова модель готова.
  Future<bool> ensureBundledInstalled(String languageCode) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null || !voice.bundled) return false;
    if (await isInstalled(languageCode)) {
      _setStatus(languageCode, TtsModelStatus.ready);
      return true;
    }
    return await extractBundle(languageCode);
  }

  /// Распаковывает bundled-модель из ассета (`assets/tts/<locale>.tar.bz2`).
  /// Используется для ru. При ошибке кидает исключение (статус = error).
  Future<bool> extractBundle(String languageCode) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null || !voice.bundled) {
      throw ArgumentError('No bundled model for $languageCode');
    }
    if (!_inFlight.add(languageCode)) {
      debugPrint('⚠ TtsModelManager: extractBundle already in flight for $languageCode');
      return false;
    }
    try {
      _setStatus(languageCode, TtsModelStatus.extractingBundle);
      _progress[languageCode] = 0.0;
      _errors[languageCode] = null;

      debugPrint('📦 TtsModelManager: loading asset ${voice.bundleAssetPath}');
      final byteData = await rootBundle.load(voice.bundleAssetPath);
      final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes, byteData.lengthInBytes);
      _progress[languageCode] = 0.3;
      notifyListeners();

      await _extractTarBz2(bytes, voice);
      _progress[languageCode] = 1.0;
      _setStatus(languageCode, TtsModelStatus.ready);
      debugPrint('✓ TtsModelManager: bundled $languageCode installed');
      return true;
    } catch (e, st) {
      _errors[languageCode] = e.toString();
      _setStatus(languageCode, TtsModelStatus.error);
      debugPrint('✗ TtsModelManager: extractBundle($languageCode) failed: $e\n$st');
      return false;
    } finally {
      _inFlight.remove(languageCode);
    }
  }

  /// Скачивает модель по сети и распаковывает. Только для не-bundled языков.
  /// [onProgress] вызывается с долей 0.0..1.0 (объединённая: download+extract).
  Future<bool> downloadAndInstall(
    String languageCode, {
    void Function(double progress, TtsModelStatus phase)? onProgress,
  }) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null) throw ArgumentError('Unknown language $languageCode');
    if (voice.bundled) {
      // bundled качать не надо — просто распакуем ассет.
      return await extractBundle(languageCode);
    }
    if (!_inFlight.add(languageCode)) {
      debugPrint('⚠ TtsModelManager: download already in flight for $languageCode');
      return false;
    }
    File? tmpArchive;
    try {
      if (await isInstalled(languageCode)) {
        _setStatus(languageCode, TtsModelStatus.ready);
        return true;
      }
      _errors[languageCode] = null;

      // === Phase 1: download ===
      _setStatus(languageCode, TtsModelStatus.downloading);
      _progress[languageCode] = 0.0;
      final root = await _rootDir();
      await root.create(recursive: true);
      tmpArchive = File(p.join(root.path, '${voice.localeCode}.download.tar.bz2'));

      final client = http.Client();
      try {
        final req = http.Request('GET', Uri.parse(voice.url));
        final resp = await client.send(req);
        if (resp.statusCode != 200) {
          throw HttpException(
              'HTTP ${resp.statusCode} for ${voice.url}');
        }
        final total = resp.contentLength ?? voice.estimatedSizeBytes;
        int received = 0;
        final sink = tmpArchive.openWrite();
        try {
          await for (final chunk in resp.stream) {
            received += chunk.length;
            sink.add(chunk); // IOSink.add sync; flush/close ниже
            final p = total > 0 ? received / total : 0.0;
            _progress[languageCode] = p * 0.9; // download = 0..0.9
            onProgress?.call(p, TtsModelStatus.downloading);
            notifyListeners();
          }
        } finally {
          await sink.flush();
          await sink.close();
        }
      } finally {
        client.close();
      }
      debugPrint('✓ TtsModelManager: downloaded $languageCode (${tmpArchive.lengthSync()} bytes)');

      // === Phase 2: extract ===
      _setStatus(languageCode, TtsModelStatus.extracting);
      _progress[languageCode] = 0.92;
      onProgress?.call(1.0, TtsModelStatus.extracting);
      notifyListeners();

      final bytes = await tmpArchive.readAsBytes();
      await _extractTarBz2(bytes, voice);

      _progress[languageCode] = 1.0;
      _setStatus(languageCode, TtsModelStatus.ready);
      debugPrint('✓ TtsModelManager: $languageCode installed');
      return true;
    } catch (e, st) {
      _errors[languageCode] = e.toString();
      _setStatus(languageCode, TtsModelStatus.error);
      debugPrint('✗ TtsModelManager: downloadAndInstall($languageCode) failed: $e\n$st');
      return false;
    } finally {
      _inFlight.remove(languageCode);
      // Чистим временный архив.
      if (tmpArchive != null) {
        try {
          if (await tmpArchive.exists()) await tmpArchive.delete();
        } catch (_) {}
      }
    }
  }

  /// Удаляет модель для языка. no-op если не установлена.
  Future<bool> delete(String languageCode) async {
    final voice = TtsCatalog.forLanguage(languageCode);
    if (voice == null) return false;
    final dir = await modelDir(voice.localeCode);
    if (!await dir.exists()) {
      _setStatus(languageCode, TtsModelStatus.absent);
      return false;
    }
    try {
      await dir.delete(recursive: true);
      _setStatus(languageCode, TtsModelStatus.absent);
      _progress.remove(languageCode);
      debugPrint('🗑 TtsModelManager: $languageCode removed');
      return true;
    } catch (e) {
      _errors[languageCode] = e.toString();
      _setStatus(languageCode, TtsModelStatus.error);
      debugPrint('✗ TtsModelManager: delete($languageCode) failed: $e');
      return false;
    }
  }

  // -------------------------------------------------------------------
  // Внутренние методы
  // -------------------------------------------------------------------

  /// Распаковывает tar.bz2 → tts/<locale>/ с strip верхнеуровневой папки.
  /// Архив Piper: `vits-piper-XX-YY-medium/model.onnx` → `<docs>/tts/XX_YY/model.onnx`.
  Future<void> _extractTarBz2(List<int> bz2Bytes, TtsVoiceInfo voice) async {
    final targetDir = await modelDir(voice.localeCode);
    // Атомарность: распаковываем во временную папку, затем rename.
    final tmpDir = Directory('${targetDir.path}.tmp');
    if (await tmpDir.exists()) {
      try {
        await tmpDir.delete(recursive: true);
      } catch (_) {}
    }
    await tmpDir.create(recursive: true);

    // 1) BZip2 → tar bytes
    final tarBytes = BZip2Decoder().decodeBytes(bz2Bytes);
    // 2) Tar → Archive
    final archive = TarDecoder().decodeBytes(tarBytes);

    // 3) Записываем файлы, strip'ая верхнеуровневую папку.
    //    Архив содержит `vits-piper-ru_RU-irina-medium/model.onnx` → пишем в
    //    tmpDir/model.onnx.
    final voicePrefix = '${voice.voiceName}/';
    for (final file in archive.files) {
      if (!file.isFile) continue;
      String rel = file.name;
      if (rel.startsWith(voicePrefix)) {
        rel = rel.substring(voicePrefix.length);
      } else if (rel.startsWith(voice.voiceName)) {
        // на всякий случай, если архив без trailing slash
        rel = rel.substring(voice.voiceName.length);
        if (rel.startsWith('/')) rel = rel.substring(1);
      }
      if (rel.isEmpty) continue;
      final outFile = File(p.join(tmpDir.path, rel));
      await outFile.parent.create(recursive: true);
      // TarFile.content в archive 3.6 = InputStream; ZipFile.content = List<int>.
      // Defensive: поддерживаем оба через проверку типа.
      final c = file.content;
      final List<int> data;
      if (c is List<int>) {
        data = c;
      } else if (c is InputStream) {
        data = c.toUint8List();
      } else {
        // Попытка через dynamic (например для InputStreamBase).
        data = (c as dynamic).toUint8List() as List<int>;
      }
      await outFile.writeAsBytes(data, flush: true);
    }

    // 4) Проверка целостности.
    final modelFile = File(p.join(tmpDir.path, 'model.onnx'));
    final tokensFile = File(p.join(tmpDir.path, 'tokens.txt'));
    final dataDir = Directory(p.join(tmpDir.path, 'espeak-ng-data'));
    if (!await modelFile.exists() || !await tokensFile.exists()) {
      try {
        await tmpDir.delete(recursive: true);
      } catch (_) {}
      throw FileSystemException(
          'TTS model integrity check failed: model.onnx or tokens.txt missing',
          tmpDir.path);
    }
    if (!await dataDir.exists()) {
      debugPrint(
          '⚠ TtsModelManager: espeak-ng-data/ missing for ${voice.languageCode} — VITS may fail to synthesize');
    }

    // 5) Атомарный rename.
    if (await targetDir.exists()) {
      try {
        await targetDir.delete(recursive: true);
      } catch (_) {}
    }
    await tmpDir.rename(targetDir.path);
  }

  void _setStatus(String languageCode, TtsModelStatus status) {
    _status[languageCode.toLowerCase()] = status;
    notifyListeners();
  }

  /// Сканирует все модели из каталога и обновляет статус (ready/absent).
  /// Вызывается при старте приложения для корректного отображения в UI.
  Future<void> refreshAllStatuses() async {
    for (final voice in TtsCatalog.all) {
      final installed = await isInstalled(voice.languageCode);
      final cur = _status[voice.languageCode];
      // Не перетираем активные статусы (downloading/extracting).
      if (cur == TtsModelStatus.downloading ||
          cur == TtsModelStatus.extracting ||
          cur == TtsModelStatus.extractingBundle) {
        continue;
      }
      _status[voice.languageCode] =
          installed ? TtsModelStatus.ready : TtsModelStatus.absent;
    }
    notifyListeners();
  }
}
