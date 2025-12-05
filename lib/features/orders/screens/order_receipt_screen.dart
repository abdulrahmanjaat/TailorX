import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../customers/controllers/customers_controller.dart';
import '../../profile/controllers/profile_controller.dart';
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
  String _currencySymbol = '\$'; // Default, will be updated

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyFormatter.getCurrencySymbol();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final orders = ordersAsync.value ?? [];
    final order = orders.where((item) => item.id == widget.orderId).firstOrNull;

    // Get profile data for receipt
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;

    // Get customer email for sharing
    String? customerEmail;
    if (order != null) {
      final customersAsync = ref.watch(customersProvider);
      final customers = customersAsync.value ?? [];
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
                      // Shop Name (highlighted/bold) - from profile
                      Text(
                        profile?.shopName.isNotEmpty == true
                            ? profile!.shopName
                            : 'TailorX',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      // Tailor Name and Phone - from profile
                      if (profile != null && profile.name.isNotEmpty)
                        Text(
                          'Tailor: ${profile.name}',
                          style: AppTextStyles.bodyRegular,
                        ),
                      if (profile != null && profile.name.isNotEmpty)
                        const SizedBox(height: AppSizes.xs),
                      if (profile != null && profile.phone.isNotEmpty)
                        Text(
                          'Phone: ${profile.phone}',
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
                                  FutureBuilder<String>(
                                    future: CurrencyFormatter.formatAmount(
                                      item.lineTotal,
                                    ),
                                    builder: (context, snapshot) {
                                      final amount =
                                          snapshot.data ??
                                          '$_currencySymbol${item.lineTotal.toStringAsFixed(2)}';
                                      return Text(
                                        amount,
                                        style: AppTextStyles.bodyRegular
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FutureBuilder<String>(
                                    future: CurrencyFormatter.formatAmount(
                                      item.unitPrice,
                                    ),
                                    builder: (context, snapshot) {
                                      final price =
                                          snapshot.data ??
                                          '$_currencySymbol${item.unitPrice.toStringAsFixed(2)}';
                                      return Text(
                                        'Qty: ${item.quantity} × $price',
                                        style: AppTextStyles.caption,
                                      );
                                    },
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
                      FutureBuilder<String>(
                        future: CurrencyFormatter.formatAmount(order.subtotal),
                        builder: (context, snapshot) {
                          final amount =
                              snapshot.data ??
                              '$_currencySymbol${order.subtotal.toStringAsFixed(2)}';
                          return _ReceiptRow('Subtotal', amount, isBold: true);
                        },
                      ),
                      const SizedBox(height: AppSizes.sm),
                      FutureBuilder<String>(
                        future: CurrencyFormatter.formatAmount(
                          order.advanceAmount,
                        ),
                        builder: (context, snapshot) {
                          final amount =
                              snapshot.data ??
                              '$_currencySymbol${order.advanceAmount.toStringAsFixed(2)}';
                          return _ReceiptRow('Advance Amount', amount);
                        },
                      ),
                      const SizedBox(height: AppSizes.sm),
                      FutureBuilder<String>(
                        future: CurrencyFormatter.formatAmount(
                          order.remainingAmount,
                        ),
                        builder: (context, snapshot) {
                          final amount =
                              snapshot.data ??
                              '$_currencySymbol${order.remainingAmount.toStringAsFixed(2)}';
                          return _ReceiptRow(
                            'Remaining Amount',
                            amount,
                            isBold: true,
                            color: AppColors.primary,
                          );
                        },
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
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Download',
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

  /// Convert RepaintBoundary to image bytes
  Future<Uint8List> _convertReceiptToImageBytes() async {
    final RenderRepaintBoundary boundary =
        _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  /// Save receipt image to device gallery
  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      // Request storage permission if needed
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          SnackbarService.showError(
            context,
            message: 'Storage permission is required to save receipt',
          );
        }
        return;
      }

      final pngBytes = await _convertReceiptToImageBytes();

      // Save using native method channel which handles all Android versions
      const platform = MethodChannel('com.abdulrahman.tailorx_app/gallery');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipt_$timestamp.png';

      try {
        final result = await platform.invokeMethod('saveImageToGallery', {
          'imageBytes': pngBytes,
          'fileName': fileName,
        });

        if (result == true && context.mounted) {
          SnackbarService.showSuccess(
            context,
            message: 'Receipt saved to gallery',
          );
        } else if (context.mounted) {
          SnackbarService.showError(
            context,
            message: 'Failed to save receipt to gallery',
          );
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarService.showError(
            context,
            message: 'Error saving receipt: $e',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(context, message: 'Error saving receipt: $e');
      }
    }
  }

  /// Request storage permission based on Android version
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), request READ_MEDIA_IMAGES
      // For Android 10-12 (API 29-32), no permission needed for scoped storage
      // For Android 9 and below, request WRITE_EXTERNAL_STORAGE
      final androidInfo = await _getAndroidVersion();
      if (androidInfo != null && androidInfo >= 33) {
        // Android 13+: Use photos permission
        final status = await Permission.photos.status;
        if (!status.isGranted) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return true;
      } else if (androidInfo != null && androidInfo < 29) {
        // Android 9 and below: Use storage permission
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return true;
      }
      // Android 10-12: No permission needed for scoped storage when using MediaStore
      return true;
    }
    return true;
  }

  /// Get Android SDK version
  Future<int?> _getAndroidVersion() async {
    try {
      const platform = MethodChannel('com.abdulrahman.tailorx_app/gallery');
      final version = await platform.invokeMethod('getAndroidVersion');
      return version as int?;
    } catch (e) {
      return null;
    }
  }

  /// Convert image bytes to base64 string
  ///
  /// This function is available for converting receipt images to base64 format.
  /// Useful for embedding images in email HTML or other text-based sharing methods.
  /// For file-based sharing (WhatsApp, etc.), use Share.shareXFiles() with the file directly.
  // ignore: unused_element
  String _imageBytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Share receipt via WhatsApp, Email, or other apps
  ///
  /// Converts the receipt to an image and shares it.
  /// The image can be converted to base64 using _imageBytesToBase64() if needed.
  Future<void> _shareToWhatsApp(
    BuildContext context,
    OrderModel order,
    String? customerEmail,
  ) async {
    try {
      // Convert receipt to image bytes
      final pngBytes = await _convertReceiptToImageBytes();

      // Save to temporary file for sharing
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      // Get profile data for share message
      final profileAsync = ref.read(profileProvider);
      final profile = profileAsync.value;
      final shopName = (profile != null && profile.shopName.isNotEmpty)
          ? profile.shopName
          : 'TailorX';
      final tailorName = (profile != null && profile.name.isNotEmpty)
          ? profile.name
          : '';
      final phone = (profile != null && profile.phone.isNotEmpty)
          ? profile.phone
          : '';

      final orderTypes = order.items.map((item) => item.orderType).join(', ');

      final message =
          '''
*$shopName Order Receipt*
${tailorName.isNotEmpty ? 'Tailor: $tailorName\n' : ''}${phone.isNotEmpty ? 'Phone: $phone\n' : ''}
Customer: ${order.customerName}
Order ID: ${order.id}
Order Type: $orderTypes
Gender: ${order.gender}

Delivery Date: ${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}

Total: $_currencySymbol${order.totalAmount.toStringAsFixed(0)}
Advance: $_currencySymbol${order.advanceAmount.toStringAsFixed(0)}
Balance: $_currencySymbol${order.remainingAmount.toStringAsFixed(0)}

Thank you for choosing our tailoring services.
''';

      // Share the image file along with the message
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
        subject: '$shopName Order Receipt - ${order.id}',
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(
          context,
          message: 'Error sharing receipt: $e',
        );
      }
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
