package com.expense.expense_tracker

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

/**
 * Native Android NotificationListenerService that captures incoming notifications
 * and forwards them to Flutter via an EventChannel sink.
 *
 * Replaces the third-party `notification_listener_service` Flutter plugin
 * which caused ClassNotFoundException crashes.
 *
 * Lifecycle:
 *   1. Android OS binds to this service when notification access is granted
 *   2. onNotificationPosted() fires for every new notification system-wide
 *   3. We extract packageName, title, text and push them into a static EventSink
 *   4. The Flutter NotificationBridge receives the map via EventChannel stream
 */
class ExpenseNotificationListenerService : NotificationListenerService() {

    companion object {
        private const val TAG = "ExpenseNotifService"

        /**
         * Static sink set by MainActivity when the EventChannel is registered.
         * Nullable — if Flutter hasn't connected yet, notifications are silently dropped.
         */
        @Volatile
        var eventSink: io.flutter.plugin.common.EventChannel.EventSink? = null
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Listener connected to notification system")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "Listener disconnected from notification system")
    }

    /**
     * Called by Android for every new notification posted system-wide.
     * We extract the key fields and push them to Flutter via the EventSink.
     */
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return

        val packageName = sbn.packageName ?: return
        val extras = sbn.notification?.extras ?: return

        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""

        // Skip empty notifications
        if (title.isEmpty() && text.isEmpty()) return

        val data = mapOf(
            "packageName" to packageName,
            "title" to title,
            "text" to text,
            "timestamp" to sbn.postTime
        )

        try {
            eventSink?.success(data)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send notification to Flutter: ${e.message}")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // We don't need to track removals for expense detection
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
    }
}
