import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Email service for sending OTP verification codes via Gmail SMTP.
/// Credentials loaded from .env file — never hardcoded.
class EmailService {
  /// Send a 6-digit OTP code to the specified email
  Future<bool> sendOTP({
    required String recipientEmail,
    required String otpCode,
    String purpose = 'verification',
  }) async {
    final senderEmail = dotenv.env['SMTP_EMAIL'] ?? '';
    final appPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
    final senderName = dotenv.env['SMTP_SENDER_NAME'] ?? 'Expense Tracker';

    if (senderEmail.isEmpty || appPassword.isEmpty) {
      debugPrint('⚠️ SMTP credentials not configured in .env file');
      if (kDebugMode) {
        _printOtpToConsole(otpCode, recipientEmail, purpose);
        return true; // Allow flow in debug mode only
      }
      return false;
    }

    try {
      final smtpServer = gmail(senderEmail, appPassword);

      String subject;
      String htmlBody;

      switch (purpose) {
        case 'reset':
          subject = 'Reset Your Password — Expense Tracker';
          htmlBody = _buildResetEmailHtml(otpCode);
          break;
        case 'login':
          subject = 'Login Verification — Expense Tracker';
          htmlBody = _buildLoginEmailHtml(otpCode);
          break;
        default:
          subject = 'Verify Your Email — Expense Tracker';
          htmlBody = _buildVerificationEmailHtml(otpCode);
      }

      final message = Message()
        ..from = Address(senderEmail, senderName)
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..html = htmlBody;

      await send(message, smtpServer);
      return true;
    } catch (e) {
      debugPrint('Email send failed: $e');
      if (kDebugMode) {
        _printOtpToConsole(otpCode, recipientEmail, purpose);
        return true; // Only continue flow in debug mode
      }
      return false; // Production: report failure honestly
    }
  }

  void _printOtpToConsole(String otp, String email, String purpose) {
    debugPrint('══════════════════════════════════════');
    debugPrint('  🔑 OTP CODE: $otp');
    debugPrint('  📧 Email: $email');
    debugPrint('  📌 Purpose: $purpose');
    debugPrint('══════════════════════════════════════');
  }

  /// Mask email for display (e.g., "alex@gmail.com" → "a****x@gmail.com")
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;

    final name = parts[0];
    final first = name[0];
    final last = name.length > 1 ? name[name.length - 1] : '';
    final stars = '*' * (name.length - 2).clamp(2, 6);

    return '$first$stars$last@${parts[1]}';
  }

  String _buildVerificationEmailHtml(String otp) {
    return '''
    <div style="font-family: 'Inter', Arial, sans-serif; max-width: 480px; margin: 0 auto; 
                background: #0C0C1F; padding: 40px 24px; border-radius: 16px;">
      <div style="text-align: center; margin-bottom: 32px;">
        <div style="width: 72px; height: 72px; margin: 0 auto 16px; 
                    background: linear-gradient(135deg, #6C63FF, #4834DF); 
                    border-radius: 20px; display: flex; align-items: center; justify-content: center;">
          <span style="font-size: 36px;">✉️</span>
        </div>
        <h1 style="color: #E5E3FF; font-size: 24px; margin: 0 0 8px;">Verify Your Email</h1>
        <p style="color: #AAA8C3; font-size: 14px; margin: 0;">
          Use the code below to verify your email address.
        </p>
      </div>
      
      <div style="background: #17172F; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 24px;">
        <p style="color: #AAA8C3; font-size: 12px; margin: 0 0 8px; letter-spacing: 1px;">VERIFICATION CODE</p>
        <div style="font-size: 36px; font-weight: bold; color: #6C63FF; letter-spacing: 12px;">$otp</div>
      </div>
      
      <p style="color: #6E6E8A; font-size: 12px; text-align: center;">
        This code expires in <strong style="color: #4ECDC4;">5 minutes</strong>.<br>
        If you didn't request this, you can safely ignore this email.
      </p>
    </div>
    ''';
  }

  String _buildLoginEmailHtml(String otp) {
    return '''
    <div style="font-family: 'Inter', Arial, sans-serif; max-width: 480px; margin: 0 auto; 
                background: #0C0C1F; padding: 40px 24px; border-radius: 16px;">
      <div style="text-align: center; margin-bottom: 32px;">
        <div style="width: 72px; height: 72px; margin: 0 auto 16px; 
                    background: linear-gradient(135deg, #6C63FF, #4834DF); 
                    border-radius: 20px; display: flex; align-items: center; justify-content: center;">
          <span style="font-size: 36px;">🔐</span>
        </div>
        <h1 style="color: #E5E3FF; font-size: 24px; margin: 0 0 8px;">Login Verification</h1>
        <p style="color: #AAA8C3; font-size: 14px; margin: 0;">
          Someone is trying to sign in to your account.
        </p>
      </div>
      
      <div style="background: #17172F; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 24px;">
        <p style="color: #AAA8C3; font-size: 12px; margin: 0 0 8px; letter-spacing: 1px;">YOUR CODE</p>
        <div style="font-size: 36px; font-weight: bold; color: #6C63FF; letter-spacing: 12px;">$otp</div>
      </div>
      
      <p style="color: #6E6E8A; font-size: 12px; text-align: center;">
        This code expires in <strong style="color: #4ECDC4;">5 minutes</strong>.<br>
        If this wasn't you, please change your password immediately.
      </p>
    </div>
    ''';
  }

  String _buildResetEmailHtml(String otp) {
    return '''
    <div style="font-family: 'Inter', Arial, sans-serif; max-width: 480px; margin: 0 auto; 
                background: #0C0C1F; padding: 40px 24px; border-radius: 16px;">
      <div style="text-align: center; margin-bottom: 32px;">
        <div style="width: 72px; height: 72px; margin: 0 auto 16px; 
                    background: linear-gradient(135deg, #6C63FF, #4834DF); 
                    border-radius: 20px; display: flex; align-items: center; justify-content: center;">
          <span style="font-size: 36px;">🔑</span>
        </div>
        <h1 style="color: #E5E3FF; font-size: 24px; margin: 0 0 8px;">Reset Your Password</h1>
        <p style="color: #AAA8C3; font-size: 14px; margin: 0;">
          Use the code below to reset your password.
        </p>
      </div>
      
      <div style="background: #17172F; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 24px;">
        <p style="color: #AAA8C3; font-size: 12px; margin: 0 0 8px; letter-spacing: 1px;">RESET CODE</p>
        <div style="font-size: 36px; font-weight: bold; color: #6C63FF; letter-spacing: 12px;">$otp</div>
      </div>
      
      <p style="color: #6E6E8A; font-size: 12px; text-align: center;">
        This code expires in <strong style="color: #4ECDC4;">5 minutes</strong>.<br>
        If you didn't request a password reset, you can safely ignore this email.
      </p>
    </div>
    ''';
  }
}
