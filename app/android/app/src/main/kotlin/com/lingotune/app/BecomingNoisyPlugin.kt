package com.lingotune.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/**
 * Нативный детектор отключения наушников для Dart-стороны через
 * EventChannel `lingotune/becoming_noisy`.
 *
 * Зачем это нужно, если есть `audio_session.becomingNoisyEventStream`:
 * audio_session регистрирует свой BroadcastReceiver на
 * ACTION_AUDIO_BECOMING_NOISY ТОЛЬКО пока держит audio focus — и снимает
 * его при каждой деактивации сессии (TTS-хендофф в режиме обучения,
 * zombie-recovery, звонок). В этих состояниях выдёргивание наушников
 * вообще не доставляет событие в Dart → песня продолжает играть в
 * динамике. Этот плагин держит receiver независимо от audio focus,
 * пока Dart-сторона подписана.
 *
 * Receiver регистрируется в onListen и снимается в onCancel — стандартный
 * паттерн, чтобы не ловить broadcast впустую, когда воспроизведение не
 * активно (гейт «реально ли что-то звучит» выполняется на Dart-стороне).
 *
 * На targetSdk 33+ регистрация требует явного флага: это защищённый
 * системный broadcast, поэтому RECEIVER_NOT_EXPORTED.
 */
class BecomingNoisyPlugin : FlutterPlugin, EventChannel.StreamHandler {
    private var appContext: Context? = null
    private var eventChannel: EventChannel? = null
    private var noisyReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        private const val TAG = "BecomingNoisyPlugin"
        private const val CHANNEL = "lingotune/becoming_noisy"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        eventChannel = EventChannel(binding.binaryMessenger, CHANNEL)
        eventChannel!!.setStreamHandler(this)
        Log.d(TAG, "Attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        unregisterReceiver()
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        eventSink = null
        appContext = null
        Log.d(TAG, "Detached from engine")
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerReceiver()
    }

    override fun onCancel(arguments: Any?) {
        unregisterReceiver()
        eventSink = null
    }

    private fun registerReceiver() {
        val ctx = appContext ?: return
        if (noisyReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == AudioManager.ACTION_AUDIO_BECOMING_NOISY) {
                    Log.d(TAG, "ACTION_AUDIO_BECOMING_NOISY")
                    // onReceive вызывается на main thread — EventSink безопасен.
                    eventSink?.success("noisy")
                }
            }
        }
        val filter = IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                ctx.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                ctx.registerReceiver(receiver, filter)
            }
            noisyReceiver = receiver
            Log.d(TAG, "Registered becoming-noisy receiver")
        } catch (e: Exception) {
            Log.e(TAG, "Error registering becoming-noisy receiver: $e")
            eventSink?.error("REGISTER_FAILED", e.message, null)
        }
    }

    private fun unregisterReceiver() {
        val receiver = noisyReceiver ?: return
        try {
            appContext?.unregisterReceiver(receiver)
        } catch (e: Exception) {
            Log.w(TAG, "Error unregistering becoming-noisy receiver: $e")
        }
        noisyReceiver = null
    }
}
