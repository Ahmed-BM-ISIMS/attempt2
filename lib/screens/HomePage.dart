import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_patient.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.home),
        actions: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircleAvatar(child: Icon(Icons.account_circle)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ],
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
          // For now we remove orderBy until emergency_score is predicted
          //TODO orderBy('emergency_score', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading patients"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final patients = snapshot.data!.docs;

            if (patients.isEmpty) {
              return const Center(child: Text("No patients found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = snapshot.data!.docs[index];

                final name = patient['name'] ?? "Unknown";
                final age = patient['age'] ?? "N/A";
                final gender = patient['gender'] == 1 ? "Male" : "Female";
                final heartRate = patient['heart_rate'] ?? "N/A";
                final respiratoryRate = patient['respiratory_rate'] ?? "N/A";
                final oxygen = patient['oxygen_saturation'] ?? "N/A";
                final systolic = patient['systolic_bp'] ?? "N/A";
                final diastolic = patient['diastolic_bp'] ?? "N/A";
                final bpMean = patient['bp_mean'] ?? "N/A";
                final painLevel = patient['pain_level'] ?? "N/A";

                Map<int, String> conditionMap = {
                  1: 'Heart Attack',
                  2: 'Stroke',
                  3: 'Dislocated Knee',
                  4: 'Kidney Stones',
                  5: 'Appendicitis',
                  6: 'Torn ACL',
                  7: 'Bowel Obstruction',
                  8: 'Fracture',
                  9: 'Gallstones',
                  10: 'Hernia',
                };
                final condition = conditionMap[patient['condition']] ?? "Unknown";
                final orNumber = '1';
                final duration = '??';
                final emergencyScore = patient['emergency_score'] ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "Score: $emergencyScore",
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPatientPage(
                                      patientId: patient.id,
                                      patientData: patient.data() as Map<String, dynamic>,
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: Text("Delete patient $name?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('patients')
                                      .doc(patients[index].id)
                                      .delete();
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text("Edit"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text("Delete"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Case & OR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Case: $condition",
                              style: textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "OR: $orNumber",
                              style: textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Duration
                      Text(
                        "Duration: $duration",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),

                      const Divider(),

                      // Extra info
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text("Age: $age", style: textTheme.bodyMedium),
                          Text("Gender: $gender", style: textTheme.bodyMedium),
                          Text("Heart Rate: $heartRate", style: textTheme.bodyMedium),
                          Text("Respiratory Rate: $respiratoryRate", style: textTheme.bodyMedium),
                          Text("Oxygen Saturation: $oxygen%", style: textTheme.bodyMedium),
                          Text("Mean BP: $bpMean", style: textTheme.bodyMedium),
                          Text("Pain Level: $painLevel", style: textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                );

              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPatientPage(
                patientId: '',
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
