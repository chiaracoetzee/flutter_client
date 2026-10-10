package com.fluxer

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AppRestartBridge(
    private val activity: MainActivity,
) {
    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_RESTART -> {
                    restart()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun restart() {
        val launchIntent =
            activity.packageManager.getLaunchIntentForPackage(activity.packageName)
        if (launchIntent == null) {
            return
        }
        launchIntent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK,
        )
        activity.startActivity(launchIntent)
        activity.finishAffinity()
    }

    companion object {
        const val CHANNEL_NAME = "fluxer_app/app_restart"
        const val METHOD_RESTART = "restart"
    }
}
