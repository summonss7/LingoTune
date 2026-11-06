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

  group('BackgroundAudioHandler.voipLineWatchDecision', () {
    // v5.12.3, карточка lingotune-013: мессенджерский (VoIP) звонок — Viber
    // и др. — невидим для TelephonyManager, а ROM-дакинг не присылает
    // interruption-событие: музыка «лёгким фоном» играла весь разговор.
    // Наблюдатель режима линии должен ставить паузу, держать её весь разговор
    // и снимать только «свою» — не трогая beep-паузы (сообщение линию не
    // занимает, режим остаётся normal).
    test('линия занята, паузы нет, звук звучал → пауза', () {
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: true,
            lineIdle: false,
            pausedForCall: false,
            voipPauseActive: false,
            audible: true),
        VoipLineWatchAction.startPause,
      );
    });

    test('линия занята, но тишина (слушатель давно на паузе) → ничего', () {
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: true,
            lineIdle: false,
            pausedForCall: false,
            voipPauseActive: false,
            audible: false),
        VoipLineWatchAction.none,
      );
    });

    test('линия занята, пауза чужая (детектор/beep) → усыновить для быстрого '
        'resume по освобождению линии', () {
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: true,
            lineIdle: false,
            pausedForCall: true,
            voipPauseActive: false,
            audible: true),
        VoipLineWatchAction.adoptPause,
      );
      // уже усыновленная — повторно не усыновляем
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: true,
            lineIdle: false,
            pausedForCall: true,
            voipPauseActive: true,
            audible: true),
        VoipLineWatchAction.none,
      );
    });

    test('линия освободилась, пауза «наша» → resume', () {
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: true,
            lineIdle: true,
            pausedForCall: true,
            voipPauseActive: true,
            audible: false),
        VoipLineWatchAction.resume,
      );
    });

    test('линия свободна, пауза ЧУЖАЯ (beep) → НЕ снимаем (lingotune-011)', () {
      // Сообщение не занимает линию: beep-пауза живёт при idle-режиме.
      // Мгновенное снятие играло бы музыку поверх звука уведомления —
      // этим по-прежнему заведуют audio_session-end и sweep с порогами.
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: true,
            lineIdle: true,
            pausedForCall: true,
            voipPauseActive: false,
            audible: true),
        VoipLineWatchAction.none,
      );
    });

    test('режим линии недоступен (null) → полное no-op, прежняя политика', () {
      expect(
        BackgroundAudioHandler.voipLineWatchDecision(
            lineIdleKnown: false,
            lineIdle: false,
            pausedForCall: false,
            voipPauseActive: false,
            audible: true),
        VoipLineWatchAction.none,
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
