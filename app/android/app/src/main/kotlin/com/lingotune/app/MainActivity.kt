package com.lingotune.app

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    private val phoneCallPlugin = PhoneCallPlugin()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Регистрируем нативный детектор телефонного звонка (EventChannel
        // "lingotune/phone_state"). Заменяет ненадёжный на ряде ROM (ColorOS,
        // MIUI) путь через audio_session.interruptionEventStream — системный
        // дакинг медиапотока при звонке игнорирует willPauseWhenDucked, и
        // песня «тихо играет» вместо честной паузы.
        flutterEngine.plugins.add(phoneCallPlugin)
    }
}
