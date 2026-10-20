package com.lingotune.app

import android.media.audiofx.Visualizer
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Нативный анализатор играющего звука для Dart-стороны.
 *
 * MethodChannel `lingotune/audio_visualizer`: start / stop.
 * EventChannel `lingotune/audio_visualizer/events`: поток ByteArray из
 * [BAR_COUNT] байт (0..255) — логарифмически распределённые по частоте полосы
 * спектра, обновляется ~20 раз/сек, пока визуализатор запущен.
 *
 * Зачем: «псевдо»-эквалайзер на синусоидах не связан с музыкой. Здесь
 * используется системный android.media.audiofx.Visualizer, привязанный к
 * сессии 0 (глобальный выходной микс) — он отдаёт НАСТОЯЩИЙ FFT того, что
 * сейчас играет, без декодирования файла и без вмешательства в аудиотракт.
 *
 * Требования/ограничения:
 *  • разрешение RECORD_AUDIO (уже объявлено для car detection; Dart-сторона
 *    запрашивает его runtime'ом перед start);
 *  • на части ROM (особенно без Google-сервисов) Visualizer может не
 *    создаваться — конструктор кидает RuntimeException → отдаём ошибку в
 *    Dart, там включается прежняя красивая заглушка;
 *  • захват идёт с выходного микса УСТРОЙСТВА: пока LingoTune играет — это
 *    наша музыка (при одновременном фоне других пушек-звуков картинка просто
 *    «дышит» вместе с ними).
 */
class AudioVisualizerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {
    companion object {
        private const val TAG = "AudioVisualizerPlugin"
        private const val CHANNEL = "lingotune/audio_visualizer"
        private const val EVENTS = "lingotune/audio_visualizer/events"

        /** Сколько частотных полос отдаём в Dart за кадр. */
        private const val BAR_COUNT = 32

        /** Верхняя граница полезных бинов FFT (долю от всех): выше ~16 кГц
         *  музыки почти нет, а шипение тянет столбики вверх зря. */
        private const val BIN_RANGE = 0.7

        /** Нормировка: типичная полнодиапазонная синусоида даёт байт-FFT
         *  амплитуду ~180; музыка в полосе — 10..120. Делим на «громкую
         *  музыку», Dart-сторона добирает адаптивным гейном. */
        private const val MAG_SCALE = 120.0
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var sink: EventChannel.EventSink? = null
    private var visualizer: Visualizer? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, EVENTS)
        eventChannel!!.setStreamHandler(this)
        Log.d(TAG, "Attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        stopInternal()
        Log.d(TAG, "Detached from engine")
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                if (visualizer != null) {
                    result.success(true)
                    return
                }
                try {
                    val v = Visualizer(0)
                    val captureSize = Visualizer.getCaptureSizeRange()
                        .map { it.toInt() }
                        .maxOrNull()
                        ?.coerceAtMost(1024)
                        ?: 256
                    v.captureSize = captureSize
                    val rate = Visualizer.getMaxCaptureRate().toInt()
                        .coerceAtMost(20000) // ≤ 20 кадров/сек — хватит глазу
                    v.setDataCaptureListener(captureListener, rate, false, true)
                    v.setEnabled(true)
                    visualizer = v
                    Log.d(TAG, "Visualizer started (capture=$captureSize, rate=$rate)")
                    result.success(true)
                } catch (e: Exception) {
                    Log.w(TAG, "Visualizer start failed: ${e.message}")
                    result.error("VISUALIZER_FAILED", e.message, null)
                }
            }
            "stop" -> {
                stopInternal()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun stopInternal() {
        try {
            visualizer?.setEnabled(false)
        } catch (e: Exception) {
            Log.w(TAG, "disable failed: ${e.message}")
        }
        try {
            visualizer?.release()
        } catch (e: Exception) {
            Log.w(TAG, "release failed: ${e.message}")
        }
        visualizer = null
    }

    private val captureListener = object : Visualizer.OnDataCaptureListener {
        override fun onWaveFormDataCapture(
            visualizer: Visualizer,
            waveform: ByteArray,
            samplingRate: Int,
        ) {
            // waveform не запрашивали (только FFT) — не вызовется.
        }

        override fun onFftDataCapture(
            visualizer: Visualizer,
            fft: ByteArray,
            samplingRate: Int,
        ) {
            val target = sink ?: return
            val bars = fftToBars(fft)
            // Колбэк приходит с binder-потока; EventSink можно дергать
            // только с главного.
            mainHandler.post {
                try {
                    target.success(bars)
                } catch (e: Exception) {
                    Log.w(TAG, "sink send failed: ${e.message}")
                }
            }
        }
    }

    /**
     * FFT (массив signed byte: [0]=DC.real, [1]=Nyquist.real, далее пары
     * re/im) → [BAR_COUNT] нормированных 0..255 полос. Полосы логарифмические
     * (как слышит ухо): низы широкие, верхи плотные.
     */
    private fun fftToBars(fft: ByteArray): ByteArray {
        val bins = fft.size / 2
        val out = ByteArray(BAR_COUNT)
        val minBin = 1.0
        val maxBin = (bins * BIN_RANGE).coerceAtLeast(minBin + BAR_COUNT)
        for (b in 0 until BAR_COUNT) {
            val f0 = minBin * Math.pow(maxBin / minBin, b.toDouble() / BAR_COUNT)
            val f1 = minBin * Math.pow(maxBin / minBin, (b + 1.0) / BAR_COUNT)
            val i0 = f0.toInt().coerceAtLeast(1)
            val i1 = f1.toInt().coerceAtLeast(i0 + 1).coerceAtMost(bins)
            var sum = 0.0
            var peak = 0.0
            var count = 0
            for (k in i0 until i1) {
                val re = fft[2 * k].toInt()
                val im = fft[2 * k + 1].toInt()
                val mag = Math.sqrt((re * re + im * im).toDouble())
                sum += mag
                if (mag > peak) peak = mag
                count++
            }
            // Среднее сглаживает шум внутри полосы, пик ловит удары бочки.
            val mixed = if (count > 0) sum / count * 0.6 + peak * 0.4 else 0.0
            val norm = (mixed / MAG_SCALE).coerceIn(0.0, 1.0)
            out[b] = (255 * Math.pow(norm, 0.65)).toInt().toByte()
        }
        return out
    }
}
