package com.expense.expense_tracker

import android.app.Notification
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

/**
 * Native Android NotificationListenerService that captures incoming notifications.
 *
 * Flow:
 *   1. Android OS calls onNotificationPosted() for every notification
 *   2. We skip group summaries (which contain no transaction data)
 *   3. We extract ALL text fields: title, text, bigText, subText, summaryText, textLines
 *   4. We save to native SQLite FIRST (never lost) via [NotificationDatabase]
 *   5. We ALSO try to send to Flutter via EventSink for real-time updates
 *   6. If Flutter isn't active, no problem — data is safely in SQLite
 *   7. When Flutter opens, it syncs all unprocessed items from SQLite
 *
 * Handles edge cases:
 *   - GPay/PhonePe/Paytm put transaction details in bigText, not text
 *   - OEMs (Xiaomi, Oppo, Vivo) bundle notifications into group summaries
 *   - UPI apps post "Processing..." then update to "Success" (both fire onNotificationPosted)
 *   - Some apps use TEXT_LINES for inbox-style notifications
 */
class ExpenseNotificationListenerService : NotificationListenerService() {

    companion object {
        private const val TAG = "ExpenseNotifService"

        /**
         * Enable verbose debug logging that dumps full notification extras.
         * Set to true temporarily to diagnose which fields UPI apps use.
         * Check with: adb logcat -s ExpenseNotifService
         */
        private const val DEBUG_DUMP = false

        /**
         * Static sink set by MainActivity when the EventChannel is registered.
         * Nullable — if Flutter hasn't connected yet, data is still saved to SQLite.
         */
        @Volatile
        var eventSink: io.flutter.plugin.common.EventChannel.EventSink? = null
    }

    private var db: NotificationDatabase? = null

    override fun onCreate() {
        super.onCreate()
        db = NotificationDatabase.getInstance(applicationContext)
        Log.d(TAG, "Service created with SQLite queue")
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
     * Called by Android for every new notification posted system-wide,
     * INCLUDING updates to existing notifications (e.g., "Processing..." → "Success").
     *
     * ALWAYS saves to SQLite first, then also tries EventSink for real-time.
     */
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return

        val packageName = sbn.packageName ?: return
        val notification = sbn.notification ?: return
        val extras = notification.extras ?: return

        // ─── Skip group summary notifications ────────────────────────
        // On Xiaomi/Oppo/Vivo/Samsung, Android bundles notifications into
        // group summaries like "3 new notifications" with no transaction data.
        // We want the individual CHILD notifications, not the summary.
        if (isGroupSummary(notification)) {
            if (DEBUG_DUMP) {
                Log.d(TAG, "Skipping group summary from $packageName (key=${sbn.key})")
            }
            return
        }

        // ─── Extract ALL text fields from notification extras ────────
        // Different UPI apps put transaction data in different fields:
        //   - GPay: often uses bigText for full "Paid ₹500 to Swiggy" message
        //   - PhonePe: uses bigText for expanded transaction details
        //   - Paytm: mixes between text and bigText
        //   - Bank SMS: uses text or textLines for inbox-style
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() ?: ""
        val summaryText = extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT)?.toString() ?: ""

        // TEXT_LINES: used by inbox-style notifications (some banking apps)
        val textLines = extractTextLines(extras)

        // ─── Debug dump (enable DEBUG_DUMP to diagnose) ──────────────
        if (DEBUG_DUMP) {
            dumpNotification(sbn, extras, title, text, bigText, subText, summaryText, textLines)
        }

        // Skip if ALL text fields are empty (nothing to parse)
        if (title.isEmpty() && text.isEmpty() && bigText.isEmpty() && textLines.isEmpty()) {
            return
        }

        // ─── Step 1: ALWAYS save to native SQLite (never lost) ───────
        try {
            db?.insert(packageName, title, text, bigText, subText, summaryText, textLines, sbn.postTime)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to queue notification: ${e.message}")
        }

        // ─── Step 2: ALSO try to send to Flutter for real-time ───────
        val data = mapOf(
            "packageName" to packageName,
            "title" to title,
            "text" to text,
            "bigText" to bigText,
            "subText" to subText,
            "summaryText" to summaryText,
            "textLines" to textLines,
            "timestamp" to sbn.postTime
        )

        try {
            eventSink?.success(data)
        } catch (e: Exception) {
            // Flutter not active — that's fine, data is safe in SQLite
            Log.d(TAG, "EventSink unavailable (app not active), data saved to queue")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // We don't need to track removals for expense detection
    }

    /**
     * Check if a notification is a group summary.
     * Group summaries contain no useful transaction data — just
     * "3 new notifications" type messages.
     */
    private fun isGroupSummary(notification: Notification): Boolean {
        return (notification.flags and Notification.FLAG_GROUP_SUMMARY) != 0
    }

    /**
     * Extract TEXT_LINES from inbox-style notifications.
     * Returns concatenated lines separated by newline, or empty string.
     */
    private fun extractTextLines(extras: Bundle): String {
        val lines = extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES) ?: return ""
        return lines.filterNotNull().joinToString("\n") { it.toString() }
    }

    /**
     * Verbose debug dump of all notification fields.
     * Enable [DEBUG_DUMP] and check with: adb logcat -s ExpenseNotifService
     */
    private fun dumpNotification(
        sbn: StatusBarNotification,
        extras: Bundle,
        title: String,
        text: String,
        bigText: String,
        subText: String,
        summaryText: String,
        textLines: String
    ) {
        val sb = StringBuilder()
        sb.appendLine("========== NOTIFICATION ==========")
        sb.appendLine("Package: ${sbn.packageName}")
        sb.appendLine("ID: ${sbn.id}")
        sb.appendLine("Key: ${sbn.key}")
        sb.appendLine("PostTime: ${sbn.postTime}")
        sb.appendLine("GroupKey: ${sbn.notification.group}")
        sb.appendLine("IsGroupSummary: ${isGroupSummary(sbn.notification)}")
        sb.appendLine("--- Key Fields ---")
        sb.appendLine("  title: $title")
        sb.appendLine("  text: $text")
        sb.appendLine("  bigText: $bigText")
        sb.appendLine("  subText: $subText")
        sb.appendLine("  summaryText: $summaryText")
        sb.appendLine("  textLines: $textLines")
        sb.appendLine("--- All Extras ---")
        dumpBundle(extras, sb, "  ")
        sb.appendLine("==================================")
        Log.d(TAG, sb.toString())
    }

    /**
     * Recursively dump a Bundle's contents for debugging.
     */
    private fun dumpBundle(bundle: Bundle, sb: StringBuilder, indent: String = "  ") {
        for (key in bundle.keySet()) {
            try {
                val value = bundle.get(key)
                when (value) {
                    is Bundle -> {
                        sb.appendLine("$indent$key: [Bundle]")
                        dumpBundle(value, sb, "$indent  ")
                    }
                    is Array<*> -> {
                        sb.appendLine("$indent$key: [Array] ${value.joinToString(prefix = "[", postfix = "]")}")
                    }
                    else -> {
                        sb.appendLine("$indent$key = $value  (${value?.javaClass?.simpleName})")
                    }
                }
            } catch (e: Exception) {
                sb.appendLine("$indent$key = <error reading value: ${e.message}>")
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
    }
}
