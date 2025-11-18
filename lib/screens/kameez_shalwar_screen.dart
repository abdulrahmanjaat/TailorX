import 'package:flutter/material.dart';
import 'base_measurement_form.dart';
import '../models/measurement_model.dart';

class KameezShalwarMeasurementScreen extends StatelessWidget {
  final Measurement? existingMeasurement;
  const KameezShalwarMeasurementScreen({super.key, this.existingMeasurement});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final customerId =
        existingMeasurement?.customerId ?? args?['customerId'] as String?;
    final userId = existingMeasurement?.userId ?? args?['userId'] as String?;
    final fields = [
      {
        'englishLabel': 'Receiving Date',
        'urduLabel': 'تاریخ آمد',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'englishLabel': 'Delivery Date',
        'urduLabel': 'تاریخ واپسی',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'englishLabel': 'Quantity',
        'urduLabel': 'تعداد',
        'icon': Icons.numbers_rounded,
      },
      {
        'englishLabel': 'Length',
        'urduLabel': 'لمبائی',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Shoulder',
        'urduLabel': 'تیرا',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Arm',
        'urduLabel': 'بازو',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Chest',
        'urduLabel': 'چھاتی',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Waist',
        'urduLabel': 'پیٹ',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Hip',
        'urduLabel': 'ہپ',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Front',
        'urduLabel': 'فرنٹ',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Hem',
        'urduLabel': 'گھیرا',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Neck',
        'urduLabel': 'گلہ',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Shalwar Length',
        'urduLabel': 'لمبائی',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Bottom',
        'urduLabel': 'باٹم',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Front Pocket',
        'urduLabel': 'فرنٹ پاکٹ',
        'icon': Icons.check_box_outline_blank_rounded,
      },
      {
        'englishLabel': 'Hem',
        'urduLabel': 'گھیرا',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Side Pocket',
        'urduLabel': 'سائیڈ پاکٹ',
        'icon': Icons.check_box_outline_blank_rounded,
      },
      {
        'englishLabel': 'Hem',
        'urduLabel': 'گھیرا',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Inseam',
        'urduLabel': 'بین',
        'icon': Icons.straighten_rounded,
      },
      {
        'englishLabel': 'Color',
        'urduLabel': 'کالر',
        'icon': Icons.palette_rounded,
      },
      {
        'englishLabel': 'Cloth Quality',
        'urduLabel': 'کپڑے کی کوالٹی',
        'icon': Icons.texture_rounded,
      },
      {
        'englishLabel': 'Cloth Color',
        'urduLabel': 'کپڑے کا رنگ',
        'icon': Icons.color_lens_rounded,
      },
      {
        'englishLabel': 'Cloth By',
        'urduLabel': 'کپڑا ملکیت',
        'icon': Icons.person_outline_rounded,
      },
      {
        'englishLabel': 'Additional Note',
        'urduLabel': 'مزید نوٹ',
        'icon': Icons.note_alt_rounded,
        'maxLines': 5,
        'hideLabels': true,
      },
    ];
    return BaseMeasurementForm(
      title: 'Shalwar Kameez Measurements',
      garmentType: 'kameez_shalwar',
      customerId: customerId ?? '',
      userId: userId ?? '',
      existingMeasurement: existingMeasurement,
      fields: fields,
    );
  }
}
