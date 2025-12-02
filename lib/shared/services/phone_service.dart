import 'package:url_launcher/url_launcher.dart';

/// Service for handling phone calls, SMS, and WhatsApp
class PhoneService {
  PhoneService._();

  static final PhoneService instance = PhoneService._();

  /// Format phone number for Pakistan WhatsApp links
  ///
  /// Removes spaces, dashes, and other formatting characters.
  /// Ensures the number starts with country code (92 for Pakistan).
  /// Example: "+92 300 1234567" -> "923001234567"
  String _formatPhoneForWhatsApp(String phone) {
    // Remove all non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Remove + if present
    cleaned = cleaned.replaceAll('+', '');

    // If number starts with 0, replace with 92 (Pakistan country code)
    if (cleaned.startsWith('0')) {
      cleaned = '92${cleaned.substring(1)}';
    }

    // If number doesn't start with 92, add it
    if (!cleaned.startsWith('92')) {
      cleaned = '92$cleaned';
    }

    return cleaned;
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    try {
      final url = Uri.parse('whatsapp://send?phone=923001234567');
      return await canLaunchUrl(url);
    } catch (e) {
      return false;
    }
  }

  /// Open WhatsApp chat with phone number
  ///
  /// If WhatsApp is not installed, falls back to SMS.
  Future<void> openWhatsAppOrSMS(String phone) async {
    try {
      final formattedPhone = _formatPhoneForWhatsApp(phone);

      // Try WhatsApp first
      final whatsAppInstalled = await isWhatsAppInstalled();

      if (whatsAppInstalled) {
        final whatsAppUrl = Uri.parse('whatsapp://send?phone=$formattedPhone');
        if (await canLaunchUrl(whatsAppUrl)) {
          await launchUrl(
            whatsAppUrl,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          return;
        }
      }

      // Fallback to SMS if WhatsApp is not available
      await sendSMS(phone);
    } catch (e) {
      print('Error opening WhatsApp/SMS: $e');
      // Try SMS as fallback
      try {
        await sendSMS(phone);
      } catch (_) {
        rethrow;
      }
    }
  }

  /// Send SMS to phone number
  /// Note: For sms: scheme, we don't need runtime permissions as it just opens the SMS app
  Future<void> sendSMS(String phone) async {
    try {
      // Clean phone number for SMS (keep + if present, remove spaces)
      String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // For SMS, we can keep the + or remove it - both work
      // Remove + for better compatibility
      cleaned = cleaned.replaceAll('+', '');

      final smsUrl = Uri.parse('sms:$cleaned');

      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception(
          'Cannot launch SMS app. Please ensure a messaging app is installed.',
        );
      }
    } catch (e) {
      print('Error sending SMS: $e');
      rethrow;
    }
  }

  /// Make a phone call
  /// Note: For tel: scheme, we don't need runtime permissions as it just opens the dialer
  Future<void> makeCall(String phone) async {
    try {
      // Remove all non-digit characters except +
      String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // Remove + if present for tel: scheme (tel: doesn't support +)
      cleaned = cleaned.replaceAll('+', '');

      // If number starts with 0, keep it (for local calls)
      // If number starts with 92, keep it (for international format)

      final callUrl = Uri.parse('tel:$cleaned');

      if (await canLaunchUrl(callUrl)) {
        await launchUrl(callUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception(
          'Cannot launch phone dialer. Please ensure a phone app is installed.',
        );
      }
    } catch (e) {
      print('Error making call: $e');
      rethrow;
    }
  }
}
