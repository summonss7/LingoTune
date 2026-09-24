package com.lingotune.app

import android.content.Context
import android.media.AudioManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Нативный запрос «занята ли аудио-линия звонком» для Dart-стороны через
 * MethodChannel `lingotune/audio_mode`.
 *
 * Зачем: самолечение залипшей call-паузы (beep уведомления, чей парный
 * interruption-end не дошёл) до v5.8.11 жёстко требовало работающий
 * PhoneCallService (READ_PHONE_STATE): разрешение не выдано/отозвано,
 * детектор молча умер после заморозки приложения ROM-ом — и залипший beep
 * стало невозможно отличить от реального разговора, из-за чего самолечение
 * навсегда отключалось («песня доиграла — всё замерло, спасал только
 * стоп+плей»). AudioManager.getMode() не требует НИКАКИХ разрешений и
 * отвечает на вопрос напрямую: MODE_NORMAL — звонком линия не занята;
 * MODE_RINGTANCE / MODE_IN_CALL / MODE_IN_COMMUNICATION — занята
 * (включая VoIP-звонки, которые TelephonyManager вообще не видит).
 *
 * MethodChannel, а не EventChannel: значение нужно точечно в момент
 * решения (watchdog, play), круглосуточный поток событий не нужен.
 */
class AudioModePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var appContext: Context? = null
    private var methodChannel: MethodChannel? = null

    companion object {
        private const val TAG = "AudioModePlugin"
        private const val CHANNEL = "lingotune/audio_mode"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler(this)
        Log.d(TAG, "Attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        appContext = null
        Log.d(TAG, "Detached from engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getMode" -> {
                val ctx = appContext
                if (ctx == null) {
                    result.error("NO_CONTEXT", "Application context is null", null)
                    return
                }
                try {
                    val audioManager =
                        ctx.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val mode = when (audioManager.mode) {
                        AudioManager.MODE_NORMAL -> "normal"
                        AudioManager.MODE_RINGTONE -> "ringtone"
                        AudioManager.MODE_IN_CALL -> "in_call"
                        AudioManager.MODE_IN_COMMUNICATION -> "in_communication"
                        // Редкие call-режимы (MODE_CALL_SCREENING и т.п.) консервативно
                        // считаем «линия занята»: лучше один лишний цикл ожидания
                        // самолечения, чем музыка посреди разговора.
                        else -> "call_other"
                    }
                    result.success(mode)
                } catch (e: Exception) {
                    result.error("MODE_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
