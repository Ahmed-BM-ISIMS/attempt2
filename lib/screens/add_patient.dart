import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPatientPage extends StatefulWidget {
  final String? patientId;
  final Map<String, dynamic>? patientData;

  const AddPatientPage({super.key, this.patientId, this.patientData});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  // Condition Map
  final Map<String, int> _conditions = {
    'Heart Attack': 1,
    'Stroke': 2,
    'Dislocated Knee': 3,
    'Kidney Stones': 4,
    'Appendicitis': 5,
    'Torn ACL': 6,
    'Bowel Obstruction': 7,
    'Fracture': 8,
    'Gallstones': 9,
    'Hernia': 10,
  };

  int? _selectedCondition;
  int? _selectedGender;
  int _selectedPain = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _hrController = TextEditingController();
  final _rrController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _sbpController = TextEditingController();
  final _dbpController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // If we are editing, pre-fill the fields
    if (widget.patientData != null) {
      final data = widget.patientData!;
      _nameController.text = data['name'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _selectedGender = data['gender'];
      _hrController.text = data['heart_rate']?.toString() ?? '';
      _rrController.text = data['respiratory_rate']?.toString() ?? '';
      _spo2Controller.text = data['oxygen_saturation']?.toString() ?? '';
      _sbpController.text = data['systolic_bp']?.toString() ?? '';
      _dbpController.text = data['diastolic_bp']?.toString() ?? '';
      _selectedPain = data['pain_level'] ?? 0;
      _selectedCondition = data['condition'];
    }
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final sbp = int.tryParse(_sbpController.text) ?? 0;
      final dbp = int.tryParse(_dbpController.text) ?? 0;
      final map = dbp + ((sbp - dbp) / 3);

      final patientData = {
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _selectedGender ?? 0,
        'heart_rate': int.tryParse(_hrController.text) ?? 0,
        'respiratory_rate': int.tryParse(_rrController.text) ?? 0,
        'oxygen_saturation': int.tryParse(_spo2Controller.text) ?? 0,
        'systolic_bp': sbp,
        'diastolic_bp': dbp,
        'bp_mean': double.parse(map.toStringAsFixed(1)),
        'pain_level': _selectedPain,
        'condition': _selectedCondition ?? 0,
        'created_at': FieldValue.serverTimestamp(),
      };

      if (widget.patientId == null) {
        // Add new patient
        await FirebaseFirestore.instance.collection('patients').add(patientData);
      } else {
        // Update existing patient
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .update(patientData);
      }

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientId == null ? "Add Patient" : "Edit Patient"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Patient Name"),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      decoration: _inputDecoration("Age"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text("Male"),
                            value: 1,
                            groupValue: _selectedGender,
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text("Female"),
                            value: 0,
                            groupValue: _selectedGender,
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hrController,
                      decoration: _inputDecoration("Heart Rate"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rrController,
                      decoration: _inputDecoration("Respiratory Rate"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _spo2Controller,
                      decoration: _inputDecoration("Oxygen Saturation"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sbpController,
                      decoration: _inputDecoration("Systolic BP"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dbpController,
                      decoration: _inputDecoration("Diastolic BP"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    const Text("Pain Level", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Column(
                      children: [
                        RadioListTile<int>(
                          title: const Text("None"),
                          value: 0,
                          groupValue: _selectedPain,
                          onChanged: (value) => setState(() => _selectedPain = value!),
                        ),
                        RadioListTile<int>(
                          title: const Text("Mild"),
                          value: 1,
                          groupValue: _selectedPain,
                          onChanged: (value) => setState(() => _selectedPain = value!),
                        ),
                        RadioListTile<int>(
                          title: const Text("Moderate"),
                          value: 2,
                          groupValue: _selectedPain,
                          onChanged: (value) => setState(() => _selectedPain = value!),
                        ),
                        RadioListTile<int>(
                          title: const Text("Severe"),
                          value: 3,
                          groupValue: _selectedPain,
                          onChanged: (value) => setState(() => _selectedPain = value!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: _selectedCondition,
                      decoration: _inputDecoration("Condition / Case"),
                      items: _conditions.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCondition = value),
                      validator: (value) => value == null ? "Please select a condition" : null,
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePatient,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(widget.patientId == null ? "Save Patient" : "Update Patient",
                            style: const TextStyle(fontSize: 16)),
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
