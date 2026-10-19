import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lingotune/services/update_service.dart';
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

  group('checkForUpdate', () {
    test('GitHub release with newer tag and APK asset', () async {
      final body = jsonEncode({
        'tag_name': 'v99.0.0',
        'body': 'Big release\n- feature',
        'html_url': 'https://github.com/summonss7/LingoTune/releases/tag/v99.0.0',
        'assets': [
          {
            'name': 'README.txt',
            'browser_download_url': 'https://example.com/readme.txt',
            'size': 10,
          },
          {
            'name': 'LingoTune-v99.0.0.apk',
            'browser_download_url':
                'https://github.com/summonss7/LingoTune/releases/download/v99.0.0/LingoTune-v99.0.0.apk',
            'size': 12345678,
          },
        ],
      });
      final service = UpdateService(
        client: MockClient((request) async => http.Response(body, 200)),
      );

      final update = await service.checkForUpdate();

      expect(update, isNotNull);
      expect(update!.version, 'v99.0.0');
      expect(update.notes, contains('Big release'));
      expect(
        update.downloadUrl,
        contains('LingoTune-v99.0.0.apk'),
      );
      expect(update.sizeBytes, 12345678);
      expect(update.releasePageUrl, contains('releases/tag'));
    });

    test('GitHub release with same version returns null', () async {
      final body = jsonEncode({
        'tag_name': '5.8.12',
        'assets': [],
      });
      final service = UpdateService(
        client: MockClient((request) async => http.Response(body, 200)),
      );

      expect(await service.checkForUpdate(), isNull);
    });

    test('simple JSON manifest is supported', () async {
      final body = jsonEncode({
        'version': '99.1.0',
        'notes': 'manual host',
        'downloadUrl': 'https://example.com/app.apk',
        'size': 2048,
        'url': 'https://example.com/changelog',
      });
      final service = UpdateService(
        client: MockClient((request) async => http.Response(body, 200)),
      );

      final update = await service.checkForUpdate();

      expect(update, isNotNull);
      expect(update!.version, '99.1.0');
      expect(update.downloadUrl, 'https://example.com/app.apk');
      expect(update.sizeBytes, 2048);
      expect(update.releasePageUrl, 'https://example.com/changelog');
    });

    test('private repo (404) means no update, not an error', () async {
      final service = UpdateService(
        client: MockClient((request) async => http.Response('Not Found', 404)),
      );
      expect(await service.checkForUpdate(), isNull);
    });

    test('broken JSON means no update', () async {
      final service = UpdateService(
        client: MockClient((request) async => http.Response('{oops', 200)),
      );
      expect(await service.checkForUpdate(), isNull);
    });

    test('manifest URL can be overridden via preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'updateManifestUrl', 'https://example.com/manifest.json');

      final seenUrls = <Uri>[];
      final service = UpdateService(
        client: MockClient((request) async {
          seenUrls.add(request.url);
          return http.Response(
              jsonEncode({'version': '99.2.0'}), 200);
        }),
      );

      final update = await service.checkForUpdate();

      expect(seenUrls.single.toString(), 'https://example.com/manifest.json');
      expect(update!.version, '99.2.0');
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
