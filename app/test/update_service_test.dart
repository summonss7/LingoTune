import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lingotune/services/update_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('compareVersions', () {
    test('numeric parts compare beyond string order', () {
      expect(UpdateService.compareVersions('5.10.0', '5.9.12'), greaterThan(0));
      expect(UpdateService.compareVersions('5.9.12', '5.10.0'), lessThan(0));
    });

    test('missing parts are zero', () {
      expect(UpdateService.compareVersions('5.9', '5.9.0'), 0);
      expect(UpdateService.compareVersions('5.9', '5.9.1'), lessThan(0));
    });

    test('leading v and prerelease suffix are tolerated', () {
      expect(UpdateService.compareVersions('v5.9.1', '5.9.0'), greaterThan(0));
      expect(UpdateService.compareVersions('5.9.0-beta.1', '5.9.0'), 0);
      expect(UpdateService.compareVersions('6.0.0', 'v5.9.9'), greaterThan(0));
    });

    test('isNewer is strict', () {
      expect(UpdateService.isNewer('5.9.1', '5.9.0'), isTrue);
      expect(UpdateService.isNewer('5.9.0', '5.9.0'), isFalse);
      expect(UpdateService.isNewer('5.8.12', '5.9.0'), isFalse);
    });
  });

  group('AppUpdate', () {
    test('suggestedFileName strips leading v', () {
      const update = AppUpdate(version: 'v5.9.1', notes: '');
      expect(update.suggestedFileName, 'LingoTune-v5.9.1.apk');
    });
  });

  group('checkForUpdate — цепочка Aila → GitHub (lingotune-006)', () {
    test('манифест v2 Aila с большим versionCode → обновление', () async {
      final body = jsonEncode({
        'project': 'lingotune',
        'versionName': '5.12.0',
        'versionCode': 250,
        'notes': 'Семейный канал',
        'assets': [
          {
            'name': 'LingoTune-v5.12.0-release.apk',
            'url':
                'https://aila.skillcoin.pp.ua/updates/lingotune/LingoTune-v5.12.0-release.apk',
            'size': 12345678,
            'sha256': 'aa11' * 16,
            'kind': 'release',
          }
        ],
      });
      final seen = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seen.add(request.url);
          if (request.url.host == 'aila.skillcoin.pp.ua') {
            return http.Response(body, 200,
                headers: {'content-type': 'application/json; charset=utf-8'});
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.update!.version, '5.12.0');
      expect(result.update!.versionCode, 250);
      expect(result.update!.sha256, 'aa11' * 16);
      expect(result.update!.sizeBytes, 12345678);
      // Ответивший источник авторитетен — GitHub не дёргается.
      expect(seen.length, 1);
      expect(seen.single.host, 'aila.skillcoin.pp.ua');
    });

    test('равный versionCode → «у вас последняя версия», без резерва',
        () async {
      final body = jsonEncode({
        'project': 'lingotune',
        'versionName': '5.11.0',
        'versionCode': 243,
        'assets': [
          {
            'name': 'LingoTune-v5.11.0-release.apk',
            'url': 'https://aila.skillcoin.pp.ua/updates/lingotune/LingoTune-v5.11.0-release.apk',
            'sha256': 'ab' * 32,
            'kind': 'release',
          }
        ],
      });
      final seen = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seen.add(request.url);
          if (request.url.host == 'aila.skillcoin.pp.ua') {
            return http.Response(body, 200);
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.upToDate);
      expect(result.update, isNull);
      expect(seen.length, 1);
    });

    test('одинаковое versionName, но больше versionCode → обновление', () async {
      // Правило центра (UPDATES-SYSTEM.md §4): Android сверяет по versionCode.
      final body = jsonEncode({
        'versionName': '5.11.0',
        'versionCode': 999,
        'assets': [
          {'name': 'a.apk', 'url': 'https://aila.skillcoin.pp.ua/a.apk'}
        ],
      });
      final service = UpdateService(
        client: MockClient((request) async {
          if (request.url.host == 'aila.skillcoin.pp.ua') {
            return http.Response(body, 200);
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.update!.version, '5.11.0');
      expect(result.update!.versionCode, 999);
    });

    test('Aila недоступна (404) → GitHub-резерв с новым тегом', () async {
      final githubBody = jsonEncode({
        'tag_name': 'v99.0.0',
        'body': 'Big release',
        'html_url':
            'https://github.com/summonss7/LingoTune/releases/tag/v99.0.0',
        'assets': [
          {
            'name': 'LingoTune-v99.0.0.apk',
            'browser_download_url':
                'https://github.com/summonss7/LingoTune/releases/download/v99.0.0/LingoTune-v99.0.0.apk',
            'size': 12345678,
          }
        ],
      });
      final seen = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seen.add(request.url);
          if (request.url.host == 'api.github.com') {
            return http.Response(githubBody, 200);
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.update!.version, 'v99.0.0');
      expect(result.update!.notes, contains('Big release'));
      expect(result.update!.downloadUrl, contains('LingoTune-v99.0.0.apk'));
      expect(result.update!.sizeBytes, 12345678);
      expect(result.update!.releasePageUrl, contains('releases/tag'));
      // Сначала канал Aila, потом резерв.
      expect(seen.length, 2);
      expect(seen.first.host, 'aila.skillcoin.pp.ua');
      expect(seen.last.host, 'api.github.com');
    });

    test('Aila кидает исключением → GitHub-резерв', () async {
      final githubBody = jsonEncode({'tag_name': 'v99.0.0', 'assets': []});
      final service = UpdateService(
        client: MockClient((request) async {
          if (request.url.host == 'api.github.com') {
            return http.Response(githubBody, 200);
          }
          throw const SocketException('network down');
        }),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.update!.version, 'v99.0.0');
    });

    test('все источники недоступны → sourceUnavailable, не исключение',
        () async {
      final service = UpdateService(
        client: MockClient(
          (request) async => http.Response('Not Found', 404),
        ),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.sourceUnavailable);
    });

    test('битый JSON во всех источниках → sourceUnavailable', () async {
      final service = UpdateService(
        client: MockClient(
          (request) async => http.Response('{oops', 200),
        ),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.sourceUnavailable);
    });

    test('GitHub с той же версией → upToDate', () async {
      final githubBody = jsonEncode({'tag_name': '5.11.0', 'assets': []});
      final service = UpdateService(
        client: MockClient((request) async {
          if (request.url.host == 'api.github.com') {
            return http.Response(githubBody, 200);
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(result.status, UpdateCheckStatus.upToDate);
    });

    test('ручной URL приоритетнее дефолта и не дёргает его', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'updateManifestUrl', 'https://example.com/manifest.json');

      final body = jsonEncode({
        'version': '99.2.0',
        'notes': 'manual host',
        'downloadUrl': 'https://example.com/app.apk',
        'size': 2048,
        'url': 'https://example.com/changelog',
      });
      final seen = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seen.add(request.url);
          return http.Response(body, 200);
        }),
      );

      final result = await service.checkForUpdate();

      expect(seen.single.toString(), 'https://example.com/manifest.json');
      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.update!.version, '99.2.0');
      expect(result.update!.downloadUrl, 'https://example.com/app.apk');
      expect(result.update!.sizeBytes, 2048);
      expect(result.update!.releasePageUrl, 'https://example.com/changelog');
    });

    test('ручной URL недоступен → обычная цепочка Aila → GitHub', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'updateManifestUrl', 'https://example.com/manifest.json');

      final ailaBody = jsonEncode({
        'versionName': '5.12.0',
        'versionCode': 250,
        'assets': [
          {'name': 'a.apk', 'url': 'https://aila.skillcoin.pp.ua/a.apk'}
        ],
      });
      final seen = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seen.add(request.url);
          if (request.url.host == 'aila.skillcoin.pp.ua') {
            return http.Response(ailaBody, 200);
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(seen.first.host, 'example.com');
      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.update!.versionCode, 250);
    });

    test('манифест v2 без APK-asset — нечитаемый для APK-обновления', () async {
      // web-релиз (assets: []) не должен предлагать установку.
      final body = jsonEncode({
        'versionName': '9.9.9',
        'versionCode': 999,
        'web': true,
        'assets': [],
      });
      final service = UpdateService(
        client: MockClient((request) async {
          if (request.url.host == 'aila.skillcoin.pp.ua') {
            return http.Response(body, 200);
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      // Версия новее, но качать нечего — источник считается бесполезным,
      // проверка уходит в резерв (GitHub) и там честно «недоступен».
      expect(result.status, UpdateCheckStatus.sourceUnavailable);
    });
  });

  group('downloadUpdate — сверка sha256 (lingotune-006)', () {
    late Directory tempDir;
    late PathProviderPlatform originalPlatform;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('lingotune_updates_test');
      // path_provider кидает UnsupportedError вне Android — подменяем
      // платформенную реализацию на временную папку.
      originalPlatform = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    });

    tearDown(() {
      PathProviderPlatform.instance = originalPlatform;
      tempDir.deleteSync(recursive: true);
    });

    UpdateService serving(Uint8List bytes) => UpdateService(
          client: MockClient.streaming(
            (request, bodyStream) async => http.StreamedResponse(
              Stream.value(bytes),
              200,
              contentLength: bytes.length,
            ),
          ),
        );

    test('совпавший sha256 → файл сохранён и возвращён путь', () async {
      final bytes = Uint8List.fromList(List.filled(4096, 7));
      final digest = crypto.sha256.convert(bytes).toString();
      final update = AppUpdate(
        version: '5.12.0',
        notes: '',
        versionCode: 250,
        downloadUrl: 'https://aila.skillcoin.pp.ua/a.apk',
        sizeBytes: bytes.length,
        sha256: digest,
      );
      final service = serving(bytes);

      final path = await service.downloadUpdate(update);

      expect(path, isNotNull);
      expect(File(path!).readAsBytesSync(), bytes);
    });

    test('несовпавший sha256 → null и файл удалён', () async {
      final bytes = Uint8List.fromList(List.filled(2048, 1));
      final update = AppUpdate(
        version: '5.12.0',
        notes: '',
        versionCode: 250,
        downloadUrl: 'https://aila.skillcoin.pp.ua/a.apk',
        sha256: 'deadbeef' * 8,
      );
      final service = serving(bytes);

      final path = await service.downloadUpdate(update);

      expect(path, isNull);
      expect(tempDir.listSync(recursive: true).whereType<File>(), isEmpty);
    });

    test('источник без sha256 — сверка пропускается', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final update = AppUpdate(
        version: '5.9.0',
        notes: '',
        downloadUrl: 'https://example.com/old.apk',
      );
      final service = serving(bytes);

      final path = await service.downloadUpdate(update);

      expect(path, isNotNull);
      expect(File(path!).lengthSync(), bytes.length);
    });
  });

  group('parseCustomManifestUri — только https (lingotune-009)', () {
    test('https принимается в любом режиме', () {
      const url = 'https://example.com/manifest.json';
      expect(UpdateService.parseCustomManifestUri(url, allowHttp: false),
          isNotNull);
      expect(UpdateService.parseCustomManifestUri(url, allowHttp: true),
          isNotNull);
    });

    test('release-постура: http отклоняется (allowHttp: false)', () {
      expect(
          UpdateService.parseCustomManifestUri(
              'http://192.168.1.10/manifest.json',
              allowHttp: false),
          isNull);
      expect(
          UpdateService.validateCustomManifestUrl('http://192.168.1.10/m.json',
              allowHttp: false),
          UpdateSourceValidation.httpBlocked);
    });

    test('debug: http разрешён для LAN-тестов (allowHttp: true)', () {
      expect(
          UpdateService.parseCustomManifestUri(
              'http://192.168.1.10/manifest.json',
              allowHttp: true),
          isNotNull);
      expect(
          UpdateService.validateCustomManifestUrl('http://192.168.1.10/m.json',
              allowHttp: true),
          UpdateSourceValidation.ok);
    });

    test('валидация диалога: пусто — сброс, мусор — invalid', () {
      expect(UpdateService.validateCustomManifestUrl('   ', allowHttp: false),
          UpdateSourceValidation.ok);
      expect(UpdateService.validateCustomManifestUrl('не url', allowHttp: false),
          UpdateSourceValidation.invalid);
      expect(
          UpdateService.validateCustomManifestUrl('ftp://example.com/m.json',
              allowHttp: false),
          UpdateSourceValidation.invalid);
    });

    test('сохранённый http-URL в debug участвует в цепочке (LAN-тесты)', () async {
      // flutter test исполняется в debug-режиме: http по умолчанию разрешён,
      // сохранённый адрес дёргается первым — как на debug-сборке.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'updateManifestUrl', 'http://192.168.1.10/manifest.json');
      final seen = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seen.add(request.url);
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.checkForUpdate();

      expect(seen.first.host, '192.168.1.10');
      expect(result.status, UpdateCheckStatus.sourceUnavailable);
    });
  });

  group('cleartext-постура манифестов Android (lingotune-009)', () {
    test('release-манифест не разрешает cleartext', () {
      final main =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(main.contains('usesCleartextTraffic'), isFalse,
          reason: 'release-сборка должна резать http (вариант Б)');
    });

    test('debug-манифест разрешает cleartext для LAN-тестов', () {
      final debug =
          File('android/app/src/debug/AndroidManifest.xml').readAsStringSync();
      expect(debug.contains('usesCleartextTraffic="true"'), isTrue);
    });
  });

  group('custom manifest url accessors (v5.10.0)', () {
    test('null by default, round-trips through set', () async {
      expect(await UpdateService.getCustomManifestUrl(), isNull);
      await UpdateService.setCustomManifestUrl(
          '  https://example.com/manifest.json  ');
      expect(await UpdateService.getCustomManifestUrl(),
          'https://example.com/manifest.json');
    });

    test('blank value resets to default source', () async {
      await UpdateService.setCustomManifestUrl('https://example.com/m.json');
      await UpdateService.setCustomManifestUrl('   ');
      expect(await UpdateService.getCustomManifestUrl(), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('updateManifestUrl'), isFalse);
    });

    test('null value resets to default source', () async {
      await UpdateService.setCustomManifestUrl('https://example.com/m.json');
      await UpdateService.setCustomManifestUrl(null);
      expect(await UpdateService.getCustomManifestUrl(), isNull);
    });
  });

  group('auto-check throttling', () {
    test('due when never checked, not due right after mark', () async {
      expect(await UpdateService.autoCheckDue(), isTrue);
      await UpdateService.markAutoCheckDone();
      expect(await UpdateService.autoCheckDue(), isFalse);
    });
  });
}

/// path_provider без Android: все каталоги — во временную папку теста.
class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getExternalStoragePath() async => root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;
}
