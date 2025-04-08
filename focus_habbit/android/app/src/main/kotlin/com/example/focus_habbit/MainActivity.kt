package com.example.focus_habbit

import io.flutter.embedding.android.FlutterActivity
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                notificationManager.isNotificationPolicyAccessGranted) {

                when (call.method) {
                    "enableDnd" -> {
                        // 전화 등 우선 알림은 허용
                        notificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_PRIORITY)
                        result.success(true)
                    }
                    "disableDnd" -> {
                        notificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }

            } else {
                result.error("NO_PERMISSION", "DND 권한이 없습니다", null)
            }
        }
    }
}
