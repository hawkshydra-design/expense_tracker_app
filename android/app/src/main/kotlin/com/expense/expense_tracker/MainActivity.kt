package com.expense.expense_tracker

import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity registers Flutter platform channels:
 *
 * 1. MethodChannel  ("com.expense.expense_tracker/notification")
 *    - isPermissionGranted     → checks notification listener access
 *    - requestPermission       → opens system Notification Access settings
 *    - getQueuedNotifications  → returns unprocessed items from native SQLite
 *    - markNotificationsProcessed → marks synced items as processed
 *
 * 2. EventChannel   ("com.expense.expense_tracker/notifications_stream")
 *    - Real-time notification stream (when app is active)
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val METHOD_CHANNEL = "com.expense.expense_tracker/notification"
        private const val EVENT_CHANNEL = "com.expense.expense_tracker/notifications_stream"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val db = NotificationDatabase.getInstance(applicationContext)

        // ── MethodChannel: permission check, request, and queue sync ──
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
                    "getQueuedNotifications" -> {
                        try {
                            val items = db.getUnprocessed()
                            result.success(items)
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to get queued notifications: ${e.message}")
                            result.success(emptyList<Map<String, Any>>())
                        }
                    }
                    "markNotificationsProcessed" -> {
                        try {
                            val ids = (call.arguments as? List<*>)
                                ?.filterIsInstance<Number>()
                                ?.map { it.toLong() }
                                ?: emptyList()
                            db.markProcessed(ids)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to mark processed: ${e.message}")
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ── EventChannel: real-time notification stream ──────────────
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
     * Opens the system Notification Access settings page.
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
