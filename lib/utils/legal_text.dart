/// Privacy policy and terms text constants.
/// Keeps legal text out of widget files.
class LegalText {
  LegalText._();

  static const String termsAndConditions = '''
Terms & Conditions

Last updated: September 2026

By using Expense Tracker ("the App"), you agree to the following terms:

1. ACCEPTANCE OF TERMS
By downloading, installing, or using the App, you agree to be bound by these Terms & Conditions. If you do not agree, do not use the App.

2. APP PURPOSE
The App is a personal finance management tool designed to help you track expenses and income. It is for personal use only and does not provide financial advice.

3. DATA OWNERSHIP
All financial data you enter into the App belongs to you. We do not sell, share, or monetize your personal data.

4. DATA STORAGE
• Your data is stored locally on your device in an encrypted database.
• If you enable Android Auto Backup, your data may be backed up to your Google Drive account. This is managed by Android OS, not by us.
• We do not have access to your locally stored data.

5. USER RESPONSIBILITIES
• You are responsible for the accuracy of data you enter.
• You are responsible for securing your device with a screen lock.
• You are responsible for backing up your data (via CSV export or Android Backup).

6. DATA LOSS
We are not responsible for data loss caused by:
• Device damage, theft, or loss
• App uninstallation without backup
• OS updates or factory resets
• Google account issues affecting Android Backup

7. AUTO-DETECTION (ANDROID)
If you enable notification-based transaction detection:
• The App reads payment notification text to extract transaction amounts.
• Notification content is processed locally on your device.
• No notification data is sent to any server.

8. LIMITATION OF LIABILITY
The App is provided "as is" without warranty. We are not liable for any financial decisions made based on App data, or for any losses resulting from App use.

9. MODIFICATIONS
We reserve the right to modify these terms. Continued use after changes constitutes acceptance.

10. CONTACT
For questions, reach out through the app's support channel.
''';

  static const String privacyPolicy = '''
Privacy Policy

Last updated: September 2026

Your privacy is important to us. This policy explains how the App handles your data.

WHAT WE COLLECT
• Financial data you manually enter (expense/income amounts, categories, notes)
• Auto-detected transaction data from payment notifications (if enabled)
• Basic account info (email, name) for authentication.

WHAT WE DON'T COLLECT
• We don't track your location
• We don't read your contacts, photos, or files
• We don't use advertising trackers
• We don't sell your data to third parties

DATA STORAGE LOCATION
• Expenses and income: Stored locally on your device.
• Authentication: Managed by Auth service.
• Preferences: Stored locally.
• Backups: Optionally backed up to YOUR Google Drive via Android Auto Backup

DATA SHARING
We do NOT share your financial data with anyone. Period.
• Auth service handles only your login credentials (email/name)
• No analytics SDKs are included in the App
• No advertising SDKs are included in the App

DATA DELETION
• You can delete individual transactions anytime within the App
• You can export all data as CSV before deleting
• Uninstalling the App removes all local data (unless you choose "Keep data" on Android 10+)
• To delete your Auth account, use the logout option and contact support

NOTIFICATION ACCESS (ANDROID)
If you grant notification access for auto-detection:
• Only payment app notifications are processed
• Text processing happens entirely on your device
• No notification content is sent to any server

CHILDREN'S PRIVACY
The App is not intended for children under 15.

CHANGES TO THIS POLICY
We may update this policy. The "last updated" date will reflect changes.
''';
}
