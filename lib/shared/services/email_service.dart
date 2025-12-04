import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Email service for sending receipts to customers
///
/// This service uses the device's default email client to send receipts.
/// When called, it opens the email app with pre-filled recipient, subject, and body.
class EmailService {
  EmailService._();

  /// Sends a receipt email to the customer
  ///
  /// Opens the default email client with pre-filled recipient, subject, and body.
  /// Returns true if the email client was opened successfully, false otherwise.
  ///
  /// Note: This requires the user to manually send the email from their email app.
  /// For automated sending, consider implementing a backend API or using a service
  /// like SendGrid, EmailJS, or SMTP server.
  static Future<bool> sendReceiptEmail({
    required String recipientEmail,
    required String customerName,
    required String orderId,
    required List<Map<String, dynamic>> orderItems,
    required double subtotal,
    required double advanceAmount,
    required double remainingAmount,
    required DateTime deliveryDate,
    String? notes,
    String? shopName,
    String? tailorName,
    String? phone,
  }) async {
    try {
      // Build email body text
      final itemsText = orderItems
          .map((item) {
            return '${item['orderType']} - Qty: ${item['quantity']} × \$${item['unitPrice'].toStringAsFixed(2)} = \$${item['lineTotal'].toStringAsFixed(2)}';
          })
          .join('\n');

      final shopNameText = shopName?.isNotEmpty == true ? shopName! : 'TailorX';
      final tailorNameText = tailorName?.isNotEmpty == true
          ? 'Tailor: $tailorName'
          : '';
      final phoneText = phone?.isNotEmpty == true ? 'Phone: $phone' : '';

      final emailBody =
          '''
$shopNameText - Order Receipt

${tailorNameText.isNotEmpty ? '$tailorNameText\n' : ''}${phoneText.isNotEmpty ? '$phoneText\n' : ''}
Order Details:
Customer: $customerName
Order ID: $orderId
Delivery Date: ${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}

Order Items:
$itemsText

Subtotal: \$${subtotal.toStringAsFixed(2)}
Advance: \$${advanceAmount.toStringAsFixed(2)}
Remaining: \$${remainingAmount.toStringAsFixed(2)}

${notes != null && notes.isNotEmpty ? 'Notes: $notes\n' : ''}
Thank you for choosing our tailoring services.
      ''';

      // Build mailto URI with encoded subject and body
      final subject = 'Order Receipt - $orderId';
      final encodedSubject = Uri.encodeComponent(subject);
      final encodedBody = Uri.encodeComponent(emailBody);
      final mailtoUri = Uri.parse(
        'mailto:$recipientEmail?subject=$encodedSubject&body=$encodedBody',
      );

      // Launch the email client
      try {
        final launched = await launchUrl(mailtoUri);
        if (launched) {
          debugPrint('Email client opened successfully for: $recipientEmail');
          return true;
        } else {
          debugPrint('Failed to open email client');
          return false;
        }
      } catch (e) {
        debugPrint('Error opening email client: $e');
        return false;
      }
    } catch (e) {
      // Log error (in production, use proper logging)
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Checks if email service is configured
  /// Returns true as the service uses the device's default email client
  static bool get isConfigured {
    return true;
  }
}
