import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/services/background_audio_handler.dart';
import 'package:lingotune/services/study_mode_service.dart';

/// Регрессионные тесты политики прерываний (v5.12.2, карточка lingotune-011:
/// «перестаёт говорить перевод после сообщения», «песня застревает после
/// звонка+сообщения»). Проверяют пороги/окна как чистые функции — тайминги
/// поведения (sweep, эхо-дебаунс, грейс-watchdog) описаны в KNOWLEDGE.md.
void main() {
  group('BackgroundAudioHandler.stalePauseThresholdFor', () {
    test('эхо-подозрение детектится быстрее всего (6 с)', () {
      expect(
        BackgroundAudioHandler.stalePauseThresholdFor(
            fromPhoneDetector: false, echoSuspect: true),
        const Duration(seconds: 6),
      );
    });

    test('beep-пауза (interruption) — 12 с', () {
      expect(
        BackgroundAudioHandler.stalePauseThresholdFor(fromPhoneDetector: false),
        const Duration(seconds: 12),
      );
    });

    test('пауза от детектора звонка — консервативные 20 с', () {
      expect(
        BackgroundAudioHandler.stalePauseThresholdFor(
            fromPhoneDetector: true, echoSuspect: true),
        const Duration(seconds: 6),
      );
      expect(
        BackgroundAudioHandler.stalePauseThresholdFor(fromPhoneDetector: true),
        const Duration(seconds: 20),
      );
    });
  });

  group('StudyModeService.ttsWatchdogSeconds', () {
    test('обычное окно — как до фикса: est+3, пол 5, кап 12', () {
      expect(
        StudyModeService.ttsWatchdogSeconds(
            estSeconds: 4, afterInterruption: false),
        7,
      );
      expect(
        StudyModeService.ttsWatchdogSeconds(
            estSeconds: 9, afterInterruption: false),
        12,
      );
    });

    test('грейс-окно после резюма — запас +8, кап 16', () {
      // Короткая строка: раньше 7 с (ложное «зависание» первого speak после
      // beep'а), теперь 12 — drain движка + синтез + реактивация сессии
      // влезают в окно.
      expect(
        StudyModeService.ttsWatchdogSeconds(
            estSeconds: 4, afterInterruption: true),
        12,
      );
      expect(
        StudyModeService.ttsWatchdogSeconds(
            estSeconds: 9, afterInterruption: true),
        16,
      );
      expect(
        StudyModeService.ttsWatchdogSeconds(
            estSeconds: 20, afterInterruption: true),
        16, // кап
      );
    });

    test('грейс-окно всегда не уже обычного', () {
      for (var est = 1; est <= 15; est++) {
        expect(
          StudyModeService.ttsWatchdogSeconds(
              estSeconds: est, afterInterruption: true),
          greaterThanOrEqualTo(StudyModeService.ttsWatchdogSeconds(
              estSeconds: est, afterInterruption: false)),
        );
      }
    });
  });
}
