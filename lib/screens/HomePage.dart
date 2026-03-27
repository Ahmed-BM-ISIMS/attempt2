import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vitasora/core/constants/medical_constants.dart';
import 'package:vitasora/screens/Project/Drawer.dart';
import 'package:vitasora/widgets/patient_card.dart';
import 'add_patient.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('VitaSora'),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.3),
              child: const Icon(Icons.account_circle, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
              .orderBy('emergency_score', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Error loading patients\n${snapshot.error}',
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final patients = snapshot.data!.docs;

            if (patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No patients yet',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('Tap + to add your first patient',
                        style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final doc = patients[index];
                final data = doc.data() as Map<String, dynamic>;
                return PatientCard(
                  patientId: doc.id,
                  data: data,
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPatientPage(
                        patientId: doc.id,
                        patientData: data,
                      ),
                    ),
                  ),
                  onDelete: () => _confirmDelete(context, doc.id, data['name'] ?? 'Unknown'),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPatientPage()),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Patient',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String patientId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Remove patient "$name" from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .delete();
    }
  }
}
