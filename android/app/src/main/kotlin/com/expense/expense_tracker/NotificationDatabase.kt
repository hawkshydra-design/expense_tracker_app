package com.expense.expense_tracker

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log

/**
 * Native SQLite database for queuing UPI notifications.
 *
 * Notifications are stored here FIRST by the NotificationListenerService,
 * then synced to Flutter when the app opens. This ensures zero data loss
 * even when the app is in the background or killed.
 *
 * Schema v2:
 *   notification_queue(id, package_name, title, text, big_text, sub_text,
 *                      summary_text, text_lines, timestamp, processed)
 */
class NotificationDatabase private constructor(context: Context) :
    SQLiteOpenHelper(context, DB_NAME, null, DB_VERSION) {

    companion object {
        private const val TAG = "NotifDB"
        private const val DB_NAME = "notification_queue.db"
        private const val DB_VERSION = 2
        private const val TABLE = "notification_queue"

        // Column names
        private const val COL_ID = "id"
        private const val COL_PACKAGE = "package_name"
        private const val COL_TITLE = "title"
        private const val COL_TEXT = "text"
        private const val COL_BIG_TEXT = "big_text"
        private const val COL_SUB_TEXT = "sub_text"
        private const val COL_SUMMARY_TEXT = "summary_text"
        private const val COL_TEXT_LINES = "text_lines"
        private const val COL_TIMESTAMP = "timestamp"
        private const val COL_PROCESSED = "processed"

        // Max queue size — prune old processed items beyond this
        private const val MAX_PROCESSED = 500

        @Volatile
        private var instance: NotificationDatabase? = null

        fun getInstance(context: Context): NotificationDatabase {
            return instance ?: synchronized(this) {
                instance ?: NotificationDatabase(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("""
            CREATE TABLE $TABLE (
                $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COL_PACKAGE TEXT NOT NULL,
                $COL_TITLE TEXT NOT NULL DEFAULT '',
                $COL_TEXT TEXT NOT NULL DEFAULT '',
                $COL_BIG_TEXT TEXT NOT NULL DEFAULT '',
                $COL_SUB_TEXT TEXT NOT NULL DEFAULT '',
                $COL_SUMMARY_TEXT TEXT NOT NULL DEFAULT '',
                $COL_TEXT_LINES TEXT NOT NULL DEFAULT '',
                $COL_TIMESTAMP INTEGER NOT NULL,
                $COL_PROCESSED INTEGER NOT NULL DEFAULT 0
            )
        """)

        // Index for fast unprocessed queries
        db.execSQL("""
            CREATE INDEX idx_processed ON $TABLE ($COL_PROCESSED)
        """)

        Log.d(TAG, "Database created (v$DB_VERSION)")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        if (oldVersion < 2) {
            // Migration v1 → v2: add new text columns
            // Using ALTER TABLE to preserve existing data
            db.execSQL("ALTER TABLE $TABLE ADD COLUMN $COL_BIG_TEXT TEXT NOT NULL DEFAULT ''")
            db.execSQL("ALTER TABLE $TABLE ADD COLUMN $COL_SUB_TEXT TEXT NOT NULL DEFAULT ''")
            db.execSQL("ALTER TABLE $TABLE ADD COLUMN $COL_SUMMARY_TEXT TEXT NOT NULL DEFAULT ''")
            db.execSQL("ALTER TABLE $TABLE ADD COLUMN $COL_TEXT_LINES TEXT NOT NULL DEFAULT ''")
            Log.d(TAG, "Migrated database from v$oldVersion to v$newVersion")
        }
    }

    /**
     * Insert a notification into the queue.
     * Called from NotificationListenerService on every UPI notification.
     * Now stores ALL text fields for maximum parsing signal.
     */
    fun insert(
        packageName: String,
        title: String,
        text: String,
        bigText: String,
        subText: String,
        summaryText: String,
        textLines: String,
        timestamp: Long
    ): Long {
        val values = ContentValues().apply {
            put(COL_PACKAGE, packageName)
            put(COL_TITLE, title)
            put(COL_TEXT, text)
            put(COL_BIG_TEXT, bigText)
            put(COL_SUB_TEXT, subText)
            put(COL_SUMMARY_TEXT, summaryText)
            put(COL_TEXT_LINES, textLines)
            put(COL_TIMESTAMP, timestamp)
            put(COL_PROCESSED, 0)
        }

        val id = writableDatabase.insert(TABLE, null, values)
        Log.d(TAG, "Queued notification #$id from $packageName")

        // Prune old processed entries periodically
        pruneIfNeeded()

        return id
    }

    /**
     * Get all unprocessed notifications as a list of maps.
     * Called by Flutter via MethodChannel when the app opens.
     * Now includes all text fields for comprehensive parsing.
     */
    fun getUnprocessed(): List<Map<String, Any>> {
        val items = mutableListOf<Map<String, Any>>()

        val cursor = readableDatabase.query(
            TABLE,
            null,
            "$COL_PROCESSED = 0",
            null, null, null,
            "$COL_TIMESTAMP ASC"  // oldest first
        )

        cursor.use {
            while (it.moveToNext()) {
                items.add(mapOf(
                    "id" to it.getLong(it.getColumnIndexOrThrow(COL_ID)),
                    "packageName" to it.getString(it.getColumnIndexOrThrow(COL_PACKAGE)),
                    "title" to it.getString(it.getColumnIndexOrThrow(COL_TITLE)),
                    "text" to it.getString(it.getColumnIndexOrThrow(COL_TEXT)),
                    "bigText" to (getStringOrDefault(it, COL_BIG_TEXT)),
                    "subText" to (getStringOrDefault(it, COL_SUB_TEXT)),
                    "summaryText" to (getStringOrDefault(it, COL_SUMMARY_TEXT)),
                    "textLines" to (getStringOrDefault(it, COL_TEXT_LINES)),
                    "timestamp" to it.getLong(it.getColumnIndexOrThrow(COL_TIMESTAMP))
                ))
            }
        }

        Log.d(TAG, "Found ${items.size} unprocessed notifications")
        return items
    }

    /**
     * Safely get a string column, returning empty string if column doesn't exist.
     * Handles the case where DB was migrated and column might not exist in old rows.
     */
    private fun getStringOrDefault(cursor: android.database.Cursor, column: String): String {
        val idx = cursor.getColumnIndex(column)
        return if (idx >= 0) cursor.getString(idx) ?: "" else ""
    }

    /**
     * Mark specific notification IDs as processed after Flutter syncs them.
     */
    fun markProcessed(ids: List<Long>) {
        if (ids.isEmpty()) return

        val placeholders = ids.joinToString(",") { "?" }
        val args = ids.map { it.toString() }.toTypedArray()

        val count = writableDatabase.update(
            TABLE,
            ContentValues().apply { put(COL_PROCESSED, 1) },
            "$COL_ID IN ($placeholders)",
            args
        )

        Log.d(TAG, "Marked $count notifications as processed")
    }

    /**
     * Remove old processed entries to prevent DB bloat.
     */
    private fun pruneIfNeeded() {
        try {
            val cursor = readableDatabase.rawQuery(
                "SELECT COUNT(*) FROM $TABLE WHERE $COL_PROCESSED = 1",
                null
            )
            cursor.use {
                if (it.moveToFirst() && it.getInt(0) > MAX_PROCESSED) {
                    // Keep the latest MAX_PROCESSED/2 processed entries, delete the rest
                    writableDatabase.execSQL("""
                        DELETE FROM $TABLE WHERE $COL_PROCESSED = 1
                        AND $COL_ID NOT IN (
                            SELECT $COL_ID FROM $TABLE
                            WHERE $COL_PROCESSED = 1
                            ORDER BY $COL_TIMESTAMP DESC
                            LIMIT ${MAX_PROCESSED / 2}
                        )
                    """)
                    Log.d(TAG, "Pruned old processed notifications")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Prune failed: ${e.message}")
        }
    }
}
