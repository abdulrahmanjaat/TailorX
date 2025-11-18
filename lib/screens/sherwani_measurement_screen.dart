import 'package:flutter/material.dart';
import 'base_measurement_form.dart';
import '../models/measurement_model.dart';

class SherwaniMeasurementScreen extends StatelessWidget {
  final Measurement? existingMeasurement;
  const SherwaniMeasurementScreen({super.key, this.existingMeasurement});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final customerId =
        existingMeasurement?.customerId ?? args?['customerId'] as String?;
    final userId = existingMeasurement?.userId ?? args?['userId'] as String?;
    final fields = [
      {'englishLabel': 'Receiving Date', 'urduLabel': 'تاریخ آمد'},
      {'englishLabel': 'Delivery Date', 'urduLabel': 'تاریخ واپسی'},
      {'englishLabel': 'Quantity', 'urduLabel': 'تعداد'},
      {'englishLabel': 'Length', 'urduLabel': 'لمبائی'},
      {'englishLabel': 'Shoulder', 'urduLabel': 'تیرا'},
      {'englishLabel': 'Arm', 'urduLabel': 'بازو'},
      {'englishLabel': 'Chest', 'urduLabel': 'چھاتی'},
      {'englishLabel': 'Waist', 'urduLabel': 'پیٹ'},
      {'englishLabel': 'Hip', 'urduLabel': 'ہپ'},
      {'englishLabel': 'Neck', 'urduLabel': 'گلہ'},
      {'englishLabel': 'Cross', 'urduLabel': 'کراس'},
      {'englishLabel': 'Half Back Width', 'urduLabel': 'ہاف بیک'},
      {'englishLabel': 'Inseam', 'urduLabel': 'بین'},
      {'englishLabel': 'Hem', 'urduLabel': 'گھیرا'},
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
      title: 'Sherwani Measurements',
      garmentType: 'sherwani',
      customerId: customerId ?? '',
      userId: userId ?? '',
      existingMeasurement: existingMeasurement,
      fields: fields,
    );
  }
}
