import 'package:flutter/material.dart';
import 'base_measurement_form.dart';
import '../models/measurement_model.dart';

class WaistcoatMeasurementScreen extends StatelessWidget {
  final Measurement? existingMeasurement;
  const WaistcoatMeasurementScreen({super.key, this.existingMeasurement});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final customerId =
        existingMeasurement?.customerId ?? args?['customerId'] as String?;
    final userId = existingMeasurement?.userId ?? args?['userId'] as String?;
    final fields = [
      // General Info
      {'englishLabel': 'Receiving Date', 'urduLabel': 'تاریخ آمد'},
      {'englishLabel': 'Delivery Date', 'urduLabel': 'تاریخ واپسی'},
      {'englishLabel': 'Quantity', 'urduLabel': 'تعداد'},
      // Waistcoat Measurements
      {'englishLabel': 'Length', 'urduLabel': 'لمبائی'},
      {'englishLabel': 'Shoulder', 'urduLabel': 'تیرا'},
      {'englishLabel': 'Chest', 'urduLabel': 'چھاتی'},
      {'englishLabel': 'Waist', 'urduLabel': 'پیٹ'},
      {'englishLabel': 'Hip', 'urduLabel': 'ہپ'},
      {'englishLabel': 'Front', 'urduLabel': 'فرنٹ'},
      {'englishLabel': 'Neck', 'urduLabel': 'گلہ'},
      {'englishLabel': 'Inseam', 'urduLabel': 'بین'},
      {'englishLabel': 'Hem', 'urduLabel': 'گھیرا'},
      // Cloth Details
      {'englishLabel': 'Cloth Quality', 'urduLabel': 'کپڑا کوالٹی'},
      {'englishLabel': 'Cloth Color', 'urduLabel': 'کپڑا کلر'},
      {'englishLabel': 'Cloth By', 'urduLabel': 'کپڑا ملکیت'},
      // Additional Note
      {
        'englishLabel': 'Additional Note',
        'urduLabel': 'مزید نوٹ',
        'maxLines': 5,
        'hideLabels': true,
      },
    ];
    return BaseMeasurementForm(
      title: 'Waistcoat Measurements',
      garmentType: 'waistcoat',
      customerId: customerId ?? '',
      userId: userId ?? '',
      existingMeasurement: existingMeasurement,
      fields: fields,
    );
  }
}
