package com.lingotune.app

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    private val phoneCallPlugin = PhoneCallPlugin()
    private val becomingNoisyPlugin = BecomingNoisyPlugin()
    private val audioModePlugin = AudioModePlugin()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Регистрируем нативный детектор телефонного звонка (EventChannel
        // "lingotune/phone_state"). Заменяет ненадёжный на ряде ROM (ColorOS,
        // MIUI) путь через audio_session.interruptionEventStream — системный
        // дакинг медиапотока при звонке игнорирует willPauseWhenDucked, и
        // песня «тихо играет» вместо честной паузы.
        flutterEngine.plugins.add(phoneCallPlugin)
        // Нативный детектор отключения наушников (EventChannel
        // "lingotune/becoming_noisy"). audio_session держит свой receiver
        // только при активном audio focus — в TTS-хендоффе режима обучения
        // событие терялось, и песня продолжала играть в динамике.
        flutterEngine.plugins.add(becomingNoisyPlugin)
        // Точечный запрос «занята ли аудио-линия звонком» (MethodChannel
        // "lingotune/audio_mode", AudioManager.getMode()). Без READ_PHONE_STATE:
        // fallback-подтверждение «звонка нет» для самолечения залипших
        // call-пауз, когда TelephonyManager-детектор недоступен (v5.8.11).
        flutterEngine.plugins.add(audioModePlugin)
    }
}
