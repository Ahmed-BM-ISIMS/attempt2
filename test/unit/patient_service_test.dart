import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitasora/core/services/patient_service.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  late PatientService patientService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    // Setup collection reference
    when(() => mockFirestore.collection('patients')).thenReturn(mockCollection);

    patientService = PatientService(firestore: mockFirestore);
  });

  group('PatientService', () {
    test('should accept custom FirebaseFirestore instance', () {
      expect(patientService, isNotNull);
    });

    test('should have a live stream of patients sorted by emergency score', () {
      // Given
      final mockQuery = MockQuery();
      final mockSnapshot = MockQuerySnapshot();

      when(() => mockCollection.orderBy('emergency_score', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      // When
      final stream = patientService.patientsStream();

      // Then
      expect(stream, emitsInOrder([mockSnapshot]));
    });

    test('should add patient to collection', () async {
      // Given
      final patientData = {'name': 'John Doe', 'emergency_score': 7.5};
      final mockDocumentReference = MockDocumentReference();

      when(() => mockCollection.add(patientData)).thenAnswer((_) async => mockDocumentReference);

      // When
      final result = await patientService.addPatient(patientData);

      // Then
      verify(() => mockCollection.add(patientData)).called(1);
      expect(result, equals(mockDocumentReference));
    });

    test('should update patient by ID', () async {
      // Given
      const patientId = 'patient-123';
      final updatedData = {'name': 'Jane Doe', 'emergency_score': 8.0};

      when(() => mockCollection.doc(patientId)).thenReturn(mockDocument);
      when(() => mockDocument.update(updatedData)).thenAnswer((_) async => {});

      // When
      await patientService.updatePatient(patientId, updatedData);

      // Then
      verify(() => mockCollection.doc(patientId)).called(1);
      verify(() => mockDocument.update(updatedData)).called(1);
    });

    test('should delete patient by ID', () async {
      // Given
      const patientId = 'patient-123';

      when(() => mockCollection.doc(patientId)).thenReturn(mockDocument);
      when(() => mockDocument.delete()).thenAnswer((_) async => {});

      // When
      await patientService.deletePatient(patientId);

      // Then
      verify(() => mockCollection.doc(patientId)).called(1);
      verify(() => mockDocument.delete()).called(1);
    });

    test('should get patient by ID', () async {
      // Given
      const patientId = 'patient-123';
      final mockDocumentSnapshot = MockDocumentSnapshot();

      when(() => mockCollection.doc(patientId)).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

      // When
      final result = await patientService.getPatient(patientId);

      // Then
      verify(() => mockCollection.doc(patientId)).called(1);
      expect(result, equals(mockDocumentSnapshot));
    });
  });
}