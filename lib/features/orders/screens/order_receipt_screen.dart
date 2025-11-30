import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/email_service.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../customers/controllers/customers_controller.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class OrderReceiptScreen extends ConsumerStatefulWidget {
  const OrderReceiptScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderReceiptScreen> createState() => _OrderReceiptScreenState();
}

class _OrderReceiptScreenState extends ConsumerState<OrderReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    // Send email automatically when receipt screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendReceiptEmail();
    });
  }

  Future<void> _sendReceiptEmail() async {
    if (_emailSent) return;

    final orders = ref.read(ordersProvider);
    final order = orders.where((item) => item.id == widget.orderId).firstOrNull;

    if (order == null) return;

    final customers = ref.read(customersProvider);
    final customer = customers
        .where((c) => c.id == order.customerId)
        .firstOrNull;
    final customerEmail = customer?.email;

    if (customerEmail == null || customerEmail.isEmpty) return;

    // Prepare order items data
    final orderItems = order.items.map((item) {
      return {
        'orderType': item.orderType,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'lineTotal': item.lineTotal,
      };
    }).toList();

    // Send email
    final emailSent = await EmailService.sendReceiptEmail(
      recipientEmail: customerEmail,
      customerName: order.customerName,
      orderId: order.id,
      orderItems: orderItems,
      subtotal: order.subtotal,
      advanceAmount: order.advanceAmount,
      remainingAmount: order.remainingAmount,
      deliveryDate: order.deliveryDate,
      notes: order.notes,
    );

    if (mounted) {
      setState(() {
        _emailSent = true;
      });

      if (emailSent) {
        SnackbarService.showSuccess(
          context,
          message: 'Receipt sent to $customerEmail',
        );
      } else if (EmailService.isConfigured) {
        SnackbarService.showError(
          context,
          message: 'Failed to send email. Please check configuration.',
        );
      }
      // If not configured, silently skip (no error shown)
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final order = orders.where((item) => item.id == widget.orderId).firstOrNull;

    // Get customer email for future email sending
    String? customerEmail;
    if (order != null) {
      final customers = ref.watch(customersProvider);
      final customer = customers
          .where((c) => c.id == order.customerId)
          .firstOrNull;
      customerEmail = customer?.email;
    }

    if (order == null) {
      return AppScaffold(
        title: 'Order Receipt',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppSizes.md),
              Text('Order not found', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSizes.sm),
              Text(
                'The order you are looking for does not exist.',
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'Order Receipt',
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: RepaintBoundary(
                key: _receiptKey,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top-left: TailorX branding
                      Text(
                        'TailorX',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      // Shop Name (highlighted/bold)
                      Text(
                        'Premium Tailor Shop',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      // Tailor Name and Phone
                      Text(
                        'Tailor: Muhammad Ali',
                        style: AppTextStyles.bodyRegular,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Phone: +92 300 1234567',
                        style: AppTextStyles.bodyRegular,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      // Receipt title
                      Text(
                        'Order Receipt',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      _ReceiptRow('Customer Name', order.customerName),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow('Order ID', order.id),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow('Gender', order.gender),
                      const SizedBox(height: AppSizes.md),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Order Items',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.sm),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.orderType,
                                      style: AppTextStyles.bodyRegular.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    '\$${item.lineTotal.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyRegular.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      _ReceiptRow(
                        'Delivery Date',
                        '${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}',
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      _ReceiptRow(
                        'Subtotal',
                        '\$${order.subtotal.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow(
                        'Advance Amount',
                        '\$${order.advanceAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow(
                        'Remaining Amount',
                        '\$${order.remainingAmount.toStringAsFixed(2)}',
                        isBold: true,
                        color: AppColors.primary,
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.md),
                        const Divider(),
                        const SizedBox(height: AppSizes.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                order.notes!,
                                style: AppTextStyles.bodyRegular,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.xl),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Thank you for choosing our tailoring services.',
                        style: AppTextStyles.caption.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Email sending status
                      if (customerEmail != null &&
                          customerEmail.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _emailSent
                                  ? Icons.check_circle
                                  : Icons.email_outlined,
                              size: 16,
                              color: _emailSent ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: AppSizes.xs),
                            Flexible(
                              child: Text(
                                _emailSent
                                    ? 'Receipt sent to: $customerEmail'
                                    : 'Sending receipt to: $customerEmail',
                                style: AppTextStyles.caption.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: _emailSent
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Download',
                    type: AppButtonType.secondary,
                    onPressed: () => _downloadReceipt(context),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppButton(
                    label: 'Share',
                    onPressed: () =>
                        _shareToWhatsApp(context, order, customerEmail),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      if (context.mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Receipt saved to ${file.path}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(context, message: 'Error: $e');
      }
    }
  }

  Future<void> _shareToWhatsApp(
    BuildContext context,
    OrderModel order,
    String? customerEmail,
  ) async {
    final message =
        '''
*TailorX Order Receipt*

Customer: ${order.customerName}
Order ID: ${order.id}
Order Type: ${order.orderType}
Gender: ${order.gender}

Delivery Date: ${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}

Total: \$${order.totalAmount.toStringAsFixed(0)}
Advance: \$${order.advanceAmount.toStringAsFixed(0)}
Balance: \$${order.remainingAmount.toStringAsFixed(0)}

Thank you for choosing our tailoring services.
''';

    await Share.share(message);

    // Placeholder for future email sending
    // TODO: Implement email sending functionality
    // if (customerEmail != null && customerEmail.isNotEmpty) {
    //   await _sendReceiptEmail(order, customerEmail);
    // }
  }

  // Placeholder method for future email sending
  // Future<void> _sendReceiptEmail(OrderModel order, String email) async {
  //   // TODO: Implement email sending logic
  //   // This will be implemented when email service is integrated
  // }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.isBold = false, this.color});

  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyRegular.copyWith(color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyRegular.copyWith(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: color ?? Colors.black,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
