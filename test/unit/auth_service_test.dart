import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitasora/core/services/auth_service.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    authService = AuthService(auth: mockAuth);
  });

  group('AuthService', () {
    test('should accept custom FirebaseAuth instance', () {
      expect(authService, isNotNull);
    });

    test('should return current user', () {
      // Given
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // When
      final user = authService.currentUser;

      // Then
      expect(user, equals(mockUser));
      verify(() => mockAuth.currentUser).called(1);
    });

    test('should provide auth state changes stream', () {
      // Given
      final streamController = StreamController<User?>();
      when(() => mockAuth.authStateChanges()).thenAnswer((_) => streamController.stream);

      // When
      final stream = authService.authStateChanges;

      // Then
      expect(stream, equals(streamController.stream));
      verify(() => mockAuth.authStateChanges()).called(1);
    });

    test('should sign in with email and password', () async {
      // Given
      const email = 'test@example.com';
      const password = 'password123';
      final mockUserCredential = MockUserCredential();

      when(() => mockAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockUserCredential);

      // When
      final result = await authService.signIn(email: email, password: password);

      // Then
      verify(() => mockAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).called(1);
      expect(result, equals(mockUserCredential));
    });

    test('should create new account', () async {
      // Given
      const email = 'new@example.com';
      const password = 'newpassword123';
      final mockUserCredential = MockUserCredential();

      when(() => mockAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockUserCredential);

      // When
      final result = await authService.createAccount(email: email, password: password);

      // Then
      verify(() => mockAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          )).called(1);
      expect(result, equals(mockUserCredential));
    });

    test('should sign out user', () async {
      // Given
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});

      // When
      await authService.signOut();

      // Then
      verify(() => mockAuth.signOut()).called(1);
    });

    test('should send password reset email', () async {
      // Given
      const email = 'user@example.com';
      when(() => mockAuth.sendPasswordResetEmail(email: email)).thenAnswer((_) async => {});

      // When
      await authService.sendPasswordResetEmail(email: email);

      // Then
      verify(() => mockAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('should send email verification', () async {
      // Given
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async => {});

      // When
      await authService.sendEmailVerification();

      // Then
      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('should reload user', () async {
      // Given
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async => {});

      // When
      await authService.reloadUser();

      // Then
      verify(() => mockUser.reload()).called(1);
    });

    test('should check if email is verified', () {
      // Given
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(true);

      // When
      final result = authService.isEmailVerified;

      // Then
      expect(result, isTrue);
      verify(() => mockUser.emailVerified).called(1);
    });

    test('should update display name', () async {
      // Given
      const name = 'John Doe';
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.updateDisplayName(name)).thenAnswer((_) async => {});

      // When
      await authService.updateDisplayName(name);

      // Then
      verify(() => mockUser.updateDisplayName(name)).called(1);
    });

    test('should delete account', () async {
      // Given
      const email = 'user@example.com';
      const password = 'password123';
      final mockCredential = MockUserCredential();

      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.email).thenReturn(email);

      // Mock credential creation
      when(() => mockUser.reauthenticateWithCredential(any())).thenAnswer((_) async => mockCredential);
      when(() => mockUser.delete()).thenAnswer((_) async => {});
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});

      // When
      await authService.deleteAccount(email: email, password: password);

      // Then
      verify(() => mockUser.reauthenticateWithCredential(any())).called(1);
      verify(() => mockUser.delete()).called(1);
      verify(() => mockAuth.signOut()).called(1);
    });
  });
}
