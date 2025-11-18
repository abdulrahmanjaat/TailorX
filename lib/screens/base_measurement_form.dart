import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/measurement_model.dart';
import '../providers/language_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/measurement_field.dart';

class BaseMeasurementForm extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> fields;
  final String garmentType;
  final String customerId;
  final String userId;
  final Measurement? existingMeasurement;

  const BaseMeasurementForm({
    super.key,
    required this.title,
    required this.fields,
    required this.garmentType,
    required this.customerId,
    required this.userId,
    this.existingMeasurement,
  });

  @override
  State<BaseMeasurementForm> createState() => _BaseMeasurementFormState();
}

class _FormSection {
  const _FormSection({
    required this.titleEn,
    required this.titleUr,
    required this.fields,
  });

  final String titleEn;
  final String titleUr;
  final List<Map<String, dynamic>> fields;
}

class _BaseMeasurementFormState extends State<BaseMeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllers['Receiving Date'] = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _controllers['Delivery Date'] = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_deliveryDate),
    );
    if (widget.existingMeasurement != null) {
      final m = widget.existingMeasurement!;
      m.measurements.forEach((key, value) {
        _controllers[key] = TextEditingController(text: value.toString());
      });
      m.additionalDetails.forEach((key, value) {
        _controllers[key] = TextEditingController(text: value);
      });
      if (m.designNotes.isNotEmpty) {
        _controllers['Additional Note'] = TextEditingController(
          text: m.designNotes,
        );
      }
      _controllers['Delivery Date'] = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(m.deliveryDate),
      );
      _controllers['Receiving Date'] = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(m.createdAt),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isUrdu = languageProvider.isUrdu;
    final sections = _buildSections();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth =
                    constraints.maxWidth > 720 ? 640.0 : constraints.maxWidth;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final section in sections) ...[
                              _buildSectionContainer(section),
                              SizedBox(height: 18.h),
                            ],
                            _buildSaveButton(isUrdu),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSaving) const _SavingOverlay(),
        ],
      ),
    );
  }

  List<_FormSection> _buildSections() {
    final pool = List<Map<String, dynamic>>.from(widget.fields);
    final sections = <_FormSection>[];

    void addSection(String en, String ur, List<String> labels) {
      final fields = _takeFields(pool, labels);
      if (fields.isEmpty) return;
      sections.add(_FormSection(titleEn: en, titleUr: ur, fields: fields));
    }

    const generalInfo = ['Receiving Date', 'Delivery Date', 'Quantity'];
    const clothDetails = ['Cloth Quality', 'Cloth Color', 'Cloth By'];

    switch (widget.garmentType) {
      case 'kameez_shalwar':
        addSection('General Info', 'عمومی معلومات', generalInfo);
        addSection('Kameez Measurements', 'قمیض پیمائش', [
          'Length',
          'Shoulder',
          'Arm',
          'Chest',
          'Waist',
          'Hip',
          'Front',
          'Hem',
          'Neck',
        ]);
        addSection('Shalwar Measurements', 'شلوار پیمائش', [
          'Shalwar Length',
          'Bottom',
        ]);
        addSection('Additional Details', 'مزید تفصیل', [
          'Front Pocket',
          'Hem',
          'Side Pocket',
          'Hem',
          'Inseam',
          'Color',
        ]);
        addSection('Cloth Details', 'کپڑے کی تفصیل', clothDetails);
        addSection('Additional Note', 'مزید نوٹ', ['Additional Note']);
        break;
      case 'sherwani':
        addSection('General Info', 'عمومی معلومات', generalInfo);
        addSection('Sherwani Measurements', 'شیروانی پیمائش', [
          'Length',
          'Shoulder',
          'Arm',
          'Chest',
          'Waist',
          'Hip',
          'Neck',
          'Cross',
          'Half Back Width',
          'Inseam',
          'Hem',
        ]);
        addSection('Cloth Details', 'کپڑے کی تفصیل', clothDetails);
        addSection('Additional Note', 'مزید نوٹ', ['Additional Note']);
        break;
      case 'waistcoat':
        addSection('General Info', 'عمومی معلومات', generalInfo);
        addSection('Waistcoat Measurements', 'ویسٹ کوٹ پیمائش', [
          'Length',
          'Shoulder',
          'Chest',
          'Waist',
          'Hip',
          'Front',
          'Neck',
          'Inseam',
          'Hem',
        ]);
        addSection('Cloth Details', 'کپڑے کی تفصیل', clothDetails);
        addSection('Additional Note', 'مزید نوٹ', ['Additional Note']);
        break;
      case 'shirt':
        addSection('General Info', 'عمومی معلومات', generalInfo);
        addSection('Shirt Measurements', 'قمیض پیمائش', [
          'Length',
          'Shoulder',
          'Arm',
          'Chest',
          'Waist',
          'Hip',
          'Front',
          'Neck',
          'Inseam',
          'Collar',
          'Hem',
        ]);
        addSection('Cloth Details', 'کپڑے کی تفصیل', clothDetails);
        addSection('Additional Note', 'مزید نوٹ', ['Additional Note']);
        break;
      case 'coat_pent':
      case 'coat':
        addSection('General Info', 'عمومی معلومات', generalInfo);
        addSection('Coat Measurements', 'کوٹ پیمائش', [
          'Length',
          'Shoulder',
          'Arm',
          'Chest',
          'Waist',
          'Hip',
          'Cross Back',
          'Half Back',
          'Neck',
        ]);
        addSection('Pant Measurements', 'پینٹ پیمائش', [
          'Waist (Pant)',
          'Length (Pant)',
          'Hip (Pant)',
          'Thigh',
          'Knee',
          'Ankle',
          'Bottom',
        ]);
        addSection('Cloth Details', 'کپڑے کی تفصیل', clothDetails);
        addSection('Additional Note', 'مزید نوٹ', ['Additional Note']);
        break;
      default:
        if (pool.isNotEmpty) {
          sections.add(
            _FormSection(
              titleEn: 'Measurements',
              titleUr: 'پیمائش',
              fields: List<Map<String, dynamic>>.from(pool),
            ),
          );
          pool.clear();
        }
    }

    if (pool.isNotEmpty) {
      sections.add(
        _FormSection(
          titleEn: 'More Details',
          titleUr: 'مزید تفصیل',
          fields: List<Map<String, dynamic>>.from(pool),
        ),
      );
    }

    return sections;
  }

  List<Map<String, dynamic>> _takeFields(
    List<Map<String, dynamic>> pool,
    List<String> labels,
  ) {
    final extracted = <Map<String, dynamic>>[];
    for (final label in labels) {
      final index = pool.indexWhere((field) => field['englishLabel'] == label);
      if (index != -1) {
        extracted.add(pool.removeAt(index));
      }
    }
    return extracted;
  }

  Widget _buildSectionContainer(_FormSection section) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(section.titleEn, section.titleUr),
            SizedBox(height: 8.h),
            ...section.fields.map(_buildFieldWithLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String en, String ur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          en,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFFD4AF37),
          ),
        ),
        Text(
          ur,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'NotoNastaliqUrdu',
            color: Colors.black54,
          ),
        ),
        Divider(
          thickness: 1.2,
          color: const Color(0xFFE2C581).withValues(alpha: 0.5),
        ),
      ],
    );
  }

  IconData? _getFieldIcon(String label) {
    if (label.contains('Date')) return Icons.calendar_today_rounded;
    if (label == 'Quantity') return Icons.numbers_rounded;
    const measurementLabels = [
      'Length',
      'Sleeve',
      'Shoulder',
      'Chest',
      'Waist',
      'Hip',
      'Neck',
      'Cuff',
      'Collar',
      'Bottom',
      'Front',
      'Cross Back',
      'Half Back',
      'Thigh',
      'Calf',
      'Knee',
      'Around',
      'Inseam',
      'Arm',
    ];
    if (measurementLabels.contains(label)) {
      return Icons.straighten_rounded;
    }
    if (label.contains('Cloth') || label == 'Color') {
      return Icons.texture_rounded;
    }
    if (label.contains('Additional')) return Icons.note_alt_rounded;
    if (label.contains('Pocket')) return Icons.check_box_outlined;
    return null;
  }

  Widget _buildFieldWithLabel(Map<String, dynamic> field) {
    final hideLabels =
        field['hideLabels'] == true ||
        (field['englishLabel']?.contains('Additional') ?? false);
    return MeasurementField(
      field['englishLabel'] ?? '',
      field['urduLabel'] ?? '',
      maxLines: field['maxLines'] ?? 1,
      keyboardType: field['keyboardType'] ?? TextInputType.text,
      controller:
          _controllers[field['englishLabel']] ??= TextEditingController(),
      validator: (value) {
        if (field['englishLabel'] == 'Serial Number' ||
            field['englishLabel'] == 'Quantity') {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
        }
        return null;
      },
      icon: _getFieldIcon(field['englishLabel'] ?? ''),
      hideLabels: hideLabels,
    );
  }

  Widget _buildSaveButton(bool isUrdu) {
    return FilledButton(
      onPressed: _saveMeasurements,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Text(isUrdu ? 'محفوظ کریں' : 'SAVE'),
    );
  }

  Future<void> _saveMeasurements() async {
    if (!_formKey.currentState!.validate()) return;
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isUrdu = languageProvider.isUrdu;

    setState(() => _isSaving = true);
    try {
      final Map<String, double> measurements = {};
      final Map<String, String> additionalDetails = {};
      String designNotes = '';

      for (final entry in _controllers.entries) {
        final fieldName = entry.key;
        final value = entry.value.text.trim();
        if (fieldName == 'Additional Note') {
          designNotes = value;
        } else if ([
          'Cloth Quality',
          'Cloth Color',
          'Cloth By',
        ].contains(fieldName)) {
          additionalDetails[fieldName] = value;
        } else if (fieldName != 'Serial Number' &&
            fieldName != 'Receiving Date' &&
            fieldName != 'Delivery Date' &&
            fieldName != 'Quantity') {
          final doubleValue = double.tryParse(value);
          if (doubleValue != null) {
            measurements[fieldName] = doubleValue;
          } else {
            additionalDetails[fieldName] = value;
          }
        }
      }

      DateTime deliveryDate = DateTime.now().add(const Duration(days: 7));
      DateTime receivingDate = DateTime.now();
      try {
        final deliveryDateStr = _controllers['Delivery Date']?.text ?? '';
        if (deliveryDateStr.isNotEmpty) {
          deliveryDate = DateFormat('yyyy-MM-dd').parse(deliveryDateStr);
        }
        final receivingDateStr = _controllers['Receiving Date']?.text ?? '';
        if (receivingDateStr.isNotEmpty) {
          receivingDate = DateFormat('yyyy-MM-dd').parse(receivingDateStr);
        }
      } catch (_) {}

      final firestoreService = FirestoreService();
      final measurementId =
          widget.existingMeasurement?.id ??
          'meas_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';

      SectionedMeasurement? sectionedMeasurement;
      final builtSections = _buildSections();
      if (builtSections.isNotEmpty) {
        sectionedMeasurement = SectionedMeasurement(
          sections:
              builtSections
                  .map(
                    (section) => MeasurementSection(
                      sectionName: section.titleEn,
                      fields:
                          section.fields
                              .map(
                                (field) => MeasurementFieldModel(
                                  label: field['englishLabel'] ?? '',
                                  value:
                                      _controllers[field['englishLabel']]
                                          ?.text ??
                                      '',
                                ),
                              )
                              .toList(),
                    ),
                  )
                  .toList(),
        );
      }

      final measurement = Measurement(
        id: measurementId,
        garmentType: widget.garmentType,
        customerName: '',
        phone: '',
        measurements: measurements,
        additionalDetails: additionalDetails,
        designNotes: designNotes,
        createdAt: receivingDate,
        deliveryDate: deliveryDate,
        customerId: widget.customerId,
        userId: widget.userId,
      );

      await firestoreService.addMeasurement(
        measurement,
        sectionedMeasurement: sectionedMeasurement,
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu ? 'پیمائش محفوظ کر دی گئی!' : 'Measurements saved!',
          ),
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(
                'Failed to save measurement. Please try again.\n$e',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}

class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFFD4AF37)),
        ),
      ),
    );
  }
}
