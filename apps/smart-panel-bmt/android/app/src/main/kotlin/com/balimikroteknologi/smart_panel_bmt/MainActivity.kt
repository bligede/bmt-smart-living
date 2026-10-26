package com.balimikroteknologi.smartpanel.demo

import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var tone: ToneGenerator? = null
    @Suppress("DEPRECATION")
    private fun stopFeedback() {
        tone?.stopTone()
        tone?.release()
        tone = null
        (getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator)?.cancel()
    }
    @Suppress("DEPRECATION")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bmt.demo/feedback")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        stopFeedback()
                        tone = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 45)
                        tone?.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 1500)
                        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                        if (Build.VERSION.SDK_INT >= 26) {
                            vibrator?.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 200, 100, 200), -1))
                        } else { vibrator?.vibrate(longArrayOf(0, 200, 100, 200), -1) }
                        result.success(null)
                    }
                    "stop" -> { stopFeedback(); result.success(null) }
                    else -> result.notImplemented()
                }
            }
    }
    override fun onPause() { stopFeedback(); super.onPause() }
    override fun onDestroy() { stopFeedback(); super.onDestroy() }
}
