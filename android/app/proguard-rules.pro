# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep notification listener service
-keep class com.expense.expense_tracker.ExpenseNotificationListenerService { *; }

# Keep R8 from removing important annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Sqflite
-keep class com.tekartik.sqflite.** { *; }
