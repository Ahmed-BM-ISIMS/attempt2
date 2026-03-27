import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vitasora/api_service.dart';
import 'package:vitasora/core/constants/medical_constants.dart';

class AddPatientPage extends StatefulWidget {
  final String? patientId;
  final Map<String, dynamic>? patientData;

  const AddPatientPage({super.key, this.patientId, this.patientData});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _hrController = TextEditingController();
  final _rrController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _sbpController = TextEditingController();
  final _dbpController = TextEditingController();

  int? _selectedCondition;
  int? _selectedGender;
  int _selectedPain = 0;
  bool _needsSurgery = false;
  bool _isLoading = false;

  bool get _isEditing => widget.patientId != null && widget.patientId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.patientData != null) {
      final data = widget.patientData!;
      _nameController.text = data['name'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _selectedGender = (data['gender'] as num?)?.toInt();
      _hrController.text = data['heart_rate']?.toString() ?? '';
      _rrController.text = data['respiratory_rate']?.toString() ?? '';
      _spo2Controller.text = data['oxygen_saturation']?.toString() ?? '';
      _sbpController.text = data['systolic_bp']?.toString() ?? '';
      _dbpController.text = data['diastolic_bp']?.toString() ?? '';
      _selectedPain = (data['pain_level'] as num?)?.toInt() ?? 0;
      _selectedCondition = (data['condition'] as num?)?.toInt();
      _needsSurgery = (data['needs_surgery'] as num?)?.toDouble() == 1.0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _hrController.dispose();
    _rrController.dispose();
    _spo2Controller.dispose();
    _sbpController.dispose();
    _dbpController.dispose();
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? _requiredNumber(String? value, String label, int min, int max) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = num.tryParse(value);
    if (n == null) return 'Must be a number';
    if (n < min || n > max) return 'Valid range: $min–$max';
    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sbp = int.parse(_sbpController.text.trim());
      final dbp = int.parse(_dbpController.text.trim());
      final bpMean = double.parse((dbp + (sbp - dbp) / 3.0).toStringAsFixed(1));

      final age = double.parse(_ageController.text.trim());
      final gender = _selectedGender!.toDouble();
      final heartRate = double.parse(_hrController.text.trim());
      final respiratoryRate = double.parse(_rrController.text.trim());
      final oxygen = double.parse(_spo2Controller.text.trim());
      final painLevel = _selectedPain.toDouble();
      final condition = _selectedCondition!.toDouble();
      final needsSurgery = _needsSurgery ? 1.0 : 0.0;

      final features = [
        age, gender, heartRate, respiratoryRate,
        oxygen, painLevel, condition, bpMean, needsSurgery,
      ];

      // ── AI Score ────────────────────────────────────────────────────────
      double? prediction;
      try {
        prediction = await ApiService.predict(features);
      } catch (e) {
        if (!mounted) return;
        final continueAnyway = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('AI Score Unavailable'),
            content: Text(
              'Could not reach the prediction server.\n\n'
              'Error: $e\n\n'
              'Save patient without an AI score?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save Anyway'),
              ),
            ],
          ),
        );
        if (continueAnyway != true) {
          setState(() => _isLoading = false);
          return;
        }
        // null means "score unavailable" — not 0
      }

      if (!mounted) return;

      final patientData = {
        'name': _nameController.text.trim(),
        'age': age,
        'gender': gender,
        'heart_rate': heartRate,
        'respiratory_rate': respiratoryRate,
        'oxygen_saturation': oxygen,
        'systolic_bp': sbp,
        'diastolic_bp': dbp,
        'bp_mean': bpMean,
        'pain_level': painLevel,
        'condition': condition,
        'needs_surgery': needsSurgery,
        'emergency_score': prediction, // null = unavailable, not 0
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (!_isEditing) {
        patientData['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('patients')
            .add(patientData);
      } else {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .update(patientData);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save patient: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI Helpers ────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Patient' : 'Add Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Personal Info ────────────────────────────────────
                    _sectionLabel('Patient Information'),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Patient Name'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      decoration: _inputDecoration(
                          'Age (${MedicalConstants.minAge}–${MedicalConstants.maxAge})'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredNumber(v, 'Age',
                          MedicalConstants.minAge, MedicalConstants.maxAge),
                    ),
                    const SizedBox(height: 12),

                    // ── Gender ───────────────────────────────────────────
                    _sectionLabel('Gender'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('Male'),
                            value: 1,
                            groupValue: _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('Female'),
                            value: 0,
                            groupValue: _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),

                    // ── Vitals ───────────────────────────────────────────
                    _sectionLabel('Vital Signs'),
                    TextFormField(
                      controller: _hrController,
                      decoration: _inputDecoration(
                          'Heart Rate (${MedicalConstants.minHeartRate}–${MedicalConstants.maxHeartRate} bpm)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredNumber(
                          v,
                          'Heart Rate',
                          MedicalConstants.minHeartRate,
                          MedicalConstants.maxHeartRate),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rrController,
                      decoration: _inputDecoration(
                          'Respiratory Rate (${MedicalConstants.minRespiratoryRate}–${MedicalConstants.maxRespiratoryRate}/min)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredNumber(
                          v,
                          'Respiratory Rate',
                          MedicalConstants.minRespiratoryRate,
                          MedicalConstants.maxRespiratoryRate),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _spo2Controller,
                      decoration: _inputDecoration(
                          'Oxygen Saturation (${MedicalConstants.minOxygenSaturation}–${MedicalConstants.maxOxygenSaturation}%)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredNumber(
                          v,
                          'Oxygen Saturation',
                          MedicalConstants.minOxygenSaturation,
                          MedicalConstants.maxOxygenSaturation),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sbpController,
                      decoration: _inputDecoration(
                          'Systolic BP (${MedicalConstants.minSystolicBp}–${MedicalConstants.maxSystolicBp} mmHg)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredNumber(
                          v,
                          'Systolic BP',
                          MedicalConstants.minSystolicBp,
                          MedicalConstants.maxSystolicBp),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dbpController,
                      decoration: _inputDecoration(
                          'Diastolic BP (${MedicalConstants.minDiastolicBp}–${MedicalConstants.maxDiastolicBp} mmHg)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredNumber(
                          v,
                          'Diastolic BP',
                          MedicalConstants.minDiastolicBp,
                          MedicalConstants.maxDiastolicBp),
                    ),
                    const SizedBox(height: 12),

                    // ── Pain Level ───────────────────────────────────────
                    _sectionLabel('Pain Level'),
                    Wrap(
                      children: [
                        for (final entry in {
                          0: 'None',
                          1: 'Mild',
                          2: 'Moderate',
                          3: 'Severe'
                        }.entries)
                          SizedBox(
                            width: 160,
                            child: RadioListTile<int>(
                              title: Text(entry.value),
                              value: entry.key,
                              groupValue: _selectedPain,
                              onChanged: (v) =>
                                  setState(() => _selectedPain = v!),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Condition ────────────────────────────────────────
                    DropdownButtonFormField<int>(
                      value: _selectedCondition,
                      decoration: _inputDecoration('Condition / Case'),
                      items: MedicalConstants.conditionToId.entries
                          .map((e) => DropdownMenuItem<int>(
                                value: e.value,
                                child: Text(e.key),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCondition = v),
                      validator: (v) =>
                          v == null ? 'Please select a condition' : null,
                    ),
                    const SizedBox(height: 12),

                    // ── Surgery Toggle ───────────────────────────────────
                    Card(
                      color: Colors.grey[50],
                      child: SwitchListTile(
                        title: const Text('Requires Surgery'),
                        subtitle: const Text(
                            'Affects the AI priority prediction'),
                        value: _needsSurgery,
                        onChanged: (v) =>
                            setState(() => _needsSurgery = v),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Submit ───────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePatient,
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isEditing ? 'Update Patient' : 'Save Patient',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
