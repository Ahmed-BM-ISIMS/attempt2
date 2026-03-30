import 'package:cloud_firestore/cloud_firestore.dart';

/// Wraps all Firestore operations for the patients collection.
/// Screens call this instead of touching FirebaseFirestore directly.
class PatientService {
  PatientService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Live stream of all patients sorted by emergency score (highest first).
  /// Patients with a null score appear last.
  Stream<QuerySnapshot> patientsStream() => _db
      .collection('patients')
      .orderBy('emergency_score', descending: true)
      .snapshots();

  /// Paginated stream of patients sorted by emergency score (highest first).
  /// [limit] - Maximum number of patients per page
  /// [startAfterDocument] - DocumentSnapshot to start after (null for first page)
  Stream<QuerySnapshot> patientsStreamPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) {
    Query query = _db
        .collection('patients')
        .orderBy('emergency_score', descending: true)
        .limit(limit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    return query.snapshots();
  }

  /// Fetch the next page of patients for manual pagination (non-stream).
  /// Returns query results with documents for building subsequent queries.
  Future<QuerySnapshot> fetchPatientsNextPage({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    Query query = _db
        .collection('patients')
        .orderBy('emergency_score', descending: true)
        .limit(limit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    return query.get();
  }

  Future<DocumentReference> addPatient(Map<String, dynamic> data) =>
      _db.collection('patients').add(data);

  Future<void> updatePatient(String id, Map<String, dynamic> data) =>
      _db.collection('patients').doc(id).update(data);

  Future<void> deletePatient(String id) =>
      _db.collection('patients').doc(id).delete();

  Future<DocumentSnapshot> getPatient(String id) =>
      _db.collection('patients').doc(id).get();
}
