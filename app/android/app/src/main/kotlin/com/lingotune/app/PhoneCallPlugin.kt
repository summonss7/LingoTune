package com.lingotune.app

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.Executor

/**
 * Нативный детектор состояния телефонного звонка для Dart-стороны через
 * EventChannel `lingotune/phone_state`.
 *
 * Шлёт строки: `ringing` (входящий звонок), `offhook` (разговор идёт),
 * `idle` (свободно / звонок завершён).
 *
 * Зачем это нужно: системный дакинг медиапотока при звонке на ряде ROM
 * (ColorOS/Realme UI, MIUI/HyperOS, EMUI) происходит на уровне AudioPolicyManager
 * и игнорирует флаг `androidWillPauseWhenDucked` плагина `audio_session`.
 * Поэтому `audio_session.interruptionEventStream` на этих устройствах либо
 * присылает событие с задержкой, либо вовсе не присылает → песня «тихо играет»
 * весь разговор вместо честной паузы. Прямой слушатель `TelephonyManager`
 * срабатывает в момент начала звонка — гарантированно раньше системного дакинга.
 *
 * API 31+ (Android 12): используем современный `TelephonyCallback.CallStateListener`.
 * API < 31: фолбэк на устаревший `PhoneStateListener.LISTEN_CALL_STATE`.
 *
 * Требует permission `READ_PHONE_STATE` (см. AndroidManifest.xml) + рантайм-запрос
 * через `permission_handler` (`Permission.phone`) на Dart-стороне.
 */
class PhoneCallPlugin : FlutterPlugin, EventChannel.StreamHandler {
    private var appContext: Context? = null
    private var eventChannel: EventChannel? = null
    private var telephonyManager: TelephonyManager? = null

    // API 31+
    private var telephonyCallback: Any? = null
    // API < 31
    private var legacyListener: PhoneStateListener? = null

    private var eventSink: EventChannel.EventSink? = null

    private val mainExecutor = Executor { command ->
        Handler(Looper.getMainLooper()).post(command)
    }

    companion object {
        private const val TAG = "PhoneCallPlugin"
        private const val CHANNEL = "lingotune/phone_state"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        eventChannel = EventChannel(binding.binaryMessenger, CHANNEL)
        eventChannel!!.setStreamHandler(this)
        Log.d(TAG, "Attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        unregisterListener()
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        appContext = null
        Log.d(TAG, "Detached from engine")
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerListener()
        // Sticky-состояние: сразу шлём ТЕКУЩЕЕ состояние линии. Если Dart-сторона
        // переподписалась посреди звонка (пересоздание экрана плеера), без
        // этого первое событие она увидит лишь при ИЗМЕНЕНИИ состояния —
        // ringing/offhook пропущены, пауза не встанет и музыка играла бы весь
        // разговор. Также инициализирует PhoneCallService.current для дебаунса
        // эха interruption-событий.
        dispatchCurrentState()
    }

    override fun onCancel(arguments: Any?) {
        unregisterListener()
        eventSink = null
    }

    private fun registerListener() {
        val ctx = appContext ?: return
        try {
            telephonyManager =
                ctx.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            val tm = telephonyManager ?: run {
                Log.e(TAG, "TelephonyManager is null")
                return
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                registerModern(tm)
            } else {
                registerLegacy(tm)
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException registering telephony listener: ${e.message}")
            eventSink?.error("PERMISSION_DENIED", e.message, null)
        } catch (e: Exception) {
            Log.e(TAG, "Error registering telephony listener: $e")
        }
    }

    private fun registerModern(tm: TelephonyManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            registerLegacy(tm)
            return
        }
        try {
            val callback = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    dispatchState(state)
                }
            }
            tm.registerTelephonyCallback(mainExecutor, callback)
            telephonyCallback = callback
            Log.d(TAG, "Registered TelephonyCallback.CallStateListener (API 31+)")
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException on TelephonyCallback: ${e.message}")
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "TelephonyCallback failed, falling back to legacy: $e")
            registerLegacy(tm)
        }
    }

    @Suppress("DEPRECATION")
    private fun registerLegacy(tm: TelephonyManager) {
        val listener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                dispatchState(state)
            }
        }
        tm.listen(listener, PhoneStateListener.LISTEN_CALL_STATE)
        legacyListener = listener
        Log.d(TAG, "Registered PhoneStateListener (legacy)")
    }

    private fun dispatchState(state: Int) {
        val name: String = when (state) {
            TelephonyManager.CALL_STATE_RINGING -> "ringing"
            TelephonyManager.CALL_STATE_OFFHOOK -> "offhook"
            TelephonyManager.CALL_STATE_IDLE -> "idle"
            else -> return
        }
        Log.d(TAG, "Call state -> $name")
        eventSink?.success(name)
    }

    @Suppress("DEPRECATION")
    private fun dispatchCurrentState() {
        val tm = telephonyManager ?: return
        try {
            dispatchState(tm.callState)
        } catch (e: SecurityException) {
            // Нет READ_PHONE_STATE (на момент подписки) — sticky недоступен,
            // дальнейшие события придут только через зарегистрированный listener.
            Log.w(TAG, "No READ_PHONE_STATE for sticky call state: ${e.message}")
        }
    }

    private fun unregisterListener() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && telephonyCallback != null) {
                val cb = telephonyCallback
                if (cb is TelephonyCallback) {
                    telephonyManager?.unregisterTelephonyCallback(cb)
                }
            }
            if (legacyListener != null) {
                @Suppress("DEPRECATION")
                telephonyManager?.listen(legacyListener!!, PhoneStateListener.LISTEN_NONE)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error unregistering telephony listener: $e")
        }
        telephonyCallback = null
        legacyListener = null
        telephonyManager = null
    }
}
