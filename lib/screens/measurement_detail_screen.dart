import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/measurement_model.dart';
import '../providers/language_provider.dart';
import 'coat_measurement_screen.dart';
import 'kameez_shalwar_screen.dart';
import 'sherwani_measurement_screen.dart';
import 'shirt_measurement_screen.dart';
import 'waistcoat_measurement_screen.dart';

class MeasurementDetailScreen extends StatelessWidget {
  final Measurement measurement;
  const MeasurementDetailScreen({super.key, required this.measurement});

  bool get _hasSectionedData =>
      measurement.sectionedMeasurements != null &&
      measurement.sectionedMeasurements!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final garmentName = languageProvider.getTranslation(
      'garments',
      measurement.garmentType,
    );

    if (_hasSectionedData) {
      return _SectionedMeasurementView(
        measurement: measurement,
        garmentName: garmentName,
      );
    }

    final flatFields = _buildFlatFields(languageProvider.isUrdu);
    final urduLabels = _urduLabelMap;

    return _FlatMeasurementView(
      garmentName: garmentName,
      measurement: measurement,
      fields: flatFields,
      urduLabels: urduLabels,
    );
  }

  List<MapEntry<String, String>> _buildFlatFields(bool isUrdu) {
    return [
      ...measurement.measurements.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toString()),
      ),
      ...measurement.additionalDetails.entries,
      if (measurement.designNotes.isNotEmpty)
        MapEntry(
          isUrdu ? 'ڈیزائن نوٹس' : 'Design Notes',
          measurement.designNotes,
        ),
      MapEntry(
        isUrdu ? 'ڈیلیوری کی تاریخ' : 'Delivery Date',
        measurement.deliveryDate.toLocal().toString().split(' ').first,
      ),
      MapEntry(
        isUrdu ? 'بنائی گئی تاریخ' : 'Created At',
        measurement.createdAt.toLocal().toString().split(' ').first,
      ),
    ];
  }
}

class _SectionedMeasurementView extends StatelessWidget {
  const _SectionedMeasurementView({
    required this.measurement,
    required this.garmentName,
  });

  final Measurement measurement;
  final String garmentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, garmentName, measurement),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: ListView.builder(
                itemCount: measurement.sectionedMeasurements!.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        garmentName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final section =
                      measurement.sectionedMeasurements![index - 1];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.sectionName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 10.h),
                      ...section.fields.map(
                        (field) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  field.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(field.value),
                            ],
                          ),
                        ),
                      ),
                      if (index != measurement.sectionedMeasurements!.length)
                        Divider(height: 28.h),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlatMeasurementView extends StatelessWidget {
  const _FlatMeasurementView({
    required this.garmentName,
    required this.measurement,
    required this.fields,
    required this.urduLabels,
  });

  final String garmentName;
  final Measurement measurement;
  final List<MapEntry<String, String>> fields;
  final Map<String, String> urduLabels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, garmentName, measurement),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
                child: ListView.separated(
                  itemCount: fields.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          garmentName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    final entry = fields[index - 1];
                    final englishLabel = entry.key;
                    final urduLabel = urduLabels[englishLabel] ?? '';
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            englishLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (urduLabel.isNotEmpty)
                            Text(
                              urduLabel,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'NotoNastaliqUrdu',
                                color: Colors.black54,
                              ),
                            ),
                          Text(
                            entry.value,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ),
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(
  BuildContext context,
  String garmentName,
  Measurement measurement,
) {
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  return AppBar(
    centerTitle: true,
    title: Text(
      languageProvider.getText('Measurement Detail', 'پیمائش کی تفصیل'),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          final screen = _editScreenFor(measurement);
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          }
        },
      ),
    ],
  );
}

Widget? _editScreenFor(Measurement measurement) {
  switch (measurement.garmentType) {
    case 'sherwani':
      return SherwaniMeasurementScreen(existingMeasurement: measurement);
    case 'waistcoat':
      return WaistcoatMeasurementScreen(existingMeasurement: measurement);
    case 'shirt':
      return ShirtMeasurementScreen(existingMeasurement: measurement);
    case 'kameez_shalwar':
      return KameezShalwarMeasurementScreen(existingMeasurement: measurement);
    case 'coat_pent':
      return CoatMeasurementScreen(existingMeasurement: measurement);
    default:
      return null;
  }
}

const Map<String, String> _urduLabelMap = {
      'Chest': 'چھاتی',
      'Hem': 'گھیرا',
      'Length': 'لمبائی',
      'Cross': 'کراس',
      'Inseam': 'بین',
      'Shoulder': 'تیرا',
      'Waist': 'پیٹ',
      'Neck': 'گلہ',
      'Half Back Width': 'ہاف بیک',
      'Arm': 'بازو',
      'Hip': 'ہپ',
      'Cloth Quality': 'کپڑا کوالٹی',
      'Cloth By': 'کپڑا ملکیت',
      'Cloth Color': 'کپڑا کلر',
      'Delivery Date': 'تاریخ واپسی',
      'Created At': 'بنائی گئی تاریخ',
      'Quantity': 'تعداد',
      'Front': 'فرنٹ',
      'Collar': 'کالر',
      'Design Notes': 'ڈیزائن نوٹس',
};

