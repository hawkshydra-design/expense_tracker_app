package com.expense.expense_tracker

import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity registers two Flutter platform channels:
 *
 * 1. MethodChannel  ("com.expense.expense_tracker/notification")
 *    - isPermissionGranted → checks notification listener access
 *    - requestPermission   → opens system Notification Access settings
 *
 * 2. EventChannel   ("com.expense.expense_tracker/notifications_stream")
 *    - Streams notification data maps from [ExpenseNotificationListenerService]
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val METHOD_CHANNEL = "com.expense.expense_tracker/notification"
        private const val EVENT_CHANNEL = "com.expense.expense_tracker/notifications_stream"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── MethodChannel: permission check & request ──────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isPermissionGranted" -> {
                        result.success(isNotificationListenerEnabled())
                    }
                    "requestPermission" -> {
                        openNotificationListenerSettings()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // ── EventChannel: notification stream ──────────────────────
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d(TAG, "EventChannel: Flutter started listening")
                    ExpenseNotificationListenerService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "EventChannel: Flutter stopped listening")
                    ExpenseNotificationListenerService.eventSink = null
                }
            })
    }

    /**
     * Checks whether our NotificationListenerService is enabled in system settings.
     * Works on all Android API levels.
     */
    private fun isNotificationListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false

        val componentName = ComponentName(this, ExpenseNotificationListenerService::class.java)
        return flat.split(":").any {
            val cn = ComponentName.unflattenFromString(it)
            cn != null && cn == componentName
        }
    }

    /**
     * Opens the system Notification Access settings page so the user
     * can grant our app permission to read notifications.
     */
    private fun openNotificationListenerSettings() {
        try {
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            } else {
                Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open notification listener settings: ${e.message}")
        }
    }
}
