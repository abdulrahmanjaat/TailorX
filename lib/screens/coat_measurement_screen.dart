import 'package:flutter/material.dart';
import 'base_measurement_form.dart';
import '../models/measurement_model.dart';

class CoatMeasurementScreen extends StatelessWidget {
  final Measurement? existingMeasurement;
  const CoatMeasurementScreen({super.key, this.existingMeasurement});

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
      // Coat Measurements
      {'englishLabel': 'Length', 'urduLabel': 'لمبائی'},
      {'englishLabel': 'Shoulder', 'urduLabel': 'تیرا'},
      {'englishLabel': 'Arm', 'urduLabel': 'بازو'},
      {'englishLabel': 'Chest', 'urduLabel': 'چھاتی'},
      {'englishLabel': 'Waist', 'urduLabel': 'پیٹ'},
      {'englishLabel': 'Hip', 'urduLabel': 'ہپ'},
      {'englishLabel': 'Cross Back', 'urduLabel': 'کراس بیک'},
      {'englishLabel': 'Half Back', 'urduLabel': 'ہاف بیک'},
      {'englishLabel': 'Neck', 'urduLabel': 'گلہ'},
      // Pant Measurements
      {'englishLabel': 'Waist (Pant)', 'urduLabel': 'ویسٹ'},
      {'englishLabel': 'Length (Pant)', 'urduLabel': 'لمبائی'},
      {'englishLabel': 'Hip (Pant)', 'urduLabel': 'ہپ'},
      {'englishLabel': 'Thigh', 'urduLabel': 'تھائی'},
      {'englishLabel': 'Knee', 'urduLabel': 'گدری'},
      {'englishLabel': 'Ankle', 'urduLabel': 'گٹنا'},
      {'englishLabel': 'Bottom', 'urduLabel': 'باٹم'},
      // Cloth Details
      {'englishLabel': 'Cloth Quality', 'urduLabel': 'کپڑا کوالٹی'},
      {'englishLabel': 'Cloth Color', 'urduLabel': 'کپڑا کلر'},
      {'englishLabel': 'Cloth By', 'urduLabel': 'کپڑا ملکیت'},
      {
        'englishLabel': 'Additional Note',
        'urduLabel': 'مزید نوٹ',
        'maxLines': 5,
        'hideLabels': true,
      },
    ];
    return BaseMeasurementForm(
      title: 'Coat Pant Measurements',
      garmentType: 'coat_pent',
      customerId: customerId ?? '',
      userId: userId ?? '',
      existingMeasurement: existingMeasurement,
      fields: fields,
    );
  }
}
