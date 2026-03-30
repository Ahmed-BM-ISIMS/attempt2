import 'package:flutter/material.dart';
import 'package:vitasora/core/constants/medical_constants.dart';

/// Reusable card that displays one patient's data in the triage list.
class PatientCard extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientCard({
    super.key,
    required this.patientId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  // ── Score colour coding ──────────────────────────────────────────────────
  static Color _scoreColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 7) return Colors.red[700]!;
    if (score >= 4) return Colors.orange[700]!;
    return Colors.green[600]!;
  }

  static String _scoreLabel(double? score) {
    if (score == null) return 'N/A';
    return score.toStringAsFixed(1);
  }

  static String _urgencyLabel(double? score) {
    if (score == null) return 'Unknown';
    if (score >= 7) return 'CRITICAL';
    if (score >= 4) return 'URGENT';
    return 'STABLE';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final name = data['name'] ?? 'Unknown';
    final age = data['age'];
    final gender = (data['gender'] as num?)?.toInt() == 1 ? 'Male' : 'Female';
    final heartRate = data['heart_rate'];
    final respiratoryRate = data['respiratory_rate'];
    final oxygen = data['oxygen_saturation'];
    final bpMean = data['bp_mean'];
    final painLevel = data['pain_level'];
    final conditionId = (data['condition'] as num?)?.toInt();
    final condition =
        MedicalConstants.idToCondition[conditionId] ?? 'Unknown';
    final rawScore = data['emergency_score'];
    final score = rawScore != null ? (rawScore as num).toDouble() : null;

    final scoreColor = _scoreColor(score);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: scoreColor, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Score badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emergency, size: 14, color: scoreColor),
                      const SizedBox(width: 4),
                      Text(
                        _scoreLabel(score),
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Urgency chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _urgencyLabel(score),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Condition row ───────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.medical_information_outlined,
                    size: 15, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    condition,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            // ── Vitals grid ─────────────────────────────────────────────
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _vital('Age', age, ''),
                _vital('Gender', gender, ''),
                _vital('HR', heartRate, ' bpm'),
                _vital('RR', respiratoryRate, '/min'),
                _vital('SpO₂', oxygen, '%'),
                _vital('MAP', bpMean, ' mmHg'),
                _vital('Pain', painLevel, '/3'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vital(String label, dynamic value, String unit) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: value != null ? '$value$unit' : 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
