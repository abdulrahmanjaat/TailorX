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
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
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

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final order = orders.where((item) => item.id == widget.orderId).firstOrNull;

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TailorX',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Order Receipt',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: AppSizes.xl),
                      _ReceiptRow('Customer Name', order.customerName),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow('Order ID', order.id),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow('Order Type', order.orderType),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow('Gender', order.gender),
                      const SizedBox(height: AppSizes.md),
                      const Divider(),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Measurements Summary',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ...order.measurementMap.entries
                          .take(10)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.xs,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _label(entry.key),
                                    style: AppTextStyles.bodyRegular,
                                  ),
                                  Text(
                                    '${entry.value}',
                                    style: AppTextStyles.bodyRegular.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                        'Total Amount',
                        'PKR ${order.totalAmount.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow(
                        'Advance Amount',
                        'PKR ${order.advanceAmount.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _ReceiptRow(
                        'Balance',
                        'PKR ${order.remainingAmount.toStringAsFixed(0)}',
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
                    onPressed: () => _shareToWhatsApp(context, order),
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

  Future<void> _shareToWhatsApp(BuildContext context, OrderModel order) async {
    final message =
        '''
*TailorX Order Receipt*

Customer: ${order.customerName}
Order ID: ${order.id}
Order Type: ${order.orderType}
Gender: ${order.gender}

Delivery Date: ${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}

Total: PKR ${order.totalAmount.toStringAsFixed(0)}
Advance: PKR ${order.advanceAmount.toStringAsFixed(0)}
Balance: PKR ${order.remainingAmount.toStringAsFixed(0)}

Thank you for choosing our tailoring services.
''';

    await Share.share(message);
  }

  String _label(String key) {
    switch (key) {
      case 'pantLength':
        return 'Pant Length';
      case 'forkLength':
        return 'Fork Length';
      case 'backWidth':
        return 'Back Width';
      case 'frontLength':
        return 'Front Length';
      case 'shirtLength':
        return 'Shirt Length';
      case 'kameezLength':
        return 'Kameez Length';
      case 'trouserLength':
        return 'Trouser Length';
      case 'armhole':
        return 'Armhole';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }
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
      children: [
        Text(
          label,
          style: AppTextStyles.bodyRegular.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: AppTextStyles.bodyRegular.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
