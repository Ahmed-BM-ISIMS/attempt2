# CLAUDE.md
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VitaSora is a Flutter-based medical triage application that helps healthcare professionals prioritize patients based on emergency severity scores. The app uses Firebase for authentication and cloud data storage.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (select device/emulator when prompted)
flutter run

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Build for Android production
flutter build apk --release

# Build for Android app bundle
flutter build appbundle --release

# Clean build artifacts
flutter clean && flutter pub get
```

## Architecture

### State Management Pattern
The app uses **Provider** for state management with the following structure:

- **Services** (`lib/core/services/`): Singleton classes that wrap external dependencies (Firebase, HTTP)
  - `auth_service.dart`: Wraps Firebase Authentication
  - `patient_service.dart`: Wraps Firestore operations for patient data

- **Providers** (`lib/providers/`): ChangeNotifier classes that expose reactive state to the UI
  - `auth_provider.dart`: Manages authentication state, provides friendly error messages, loading states

This separation allows screens to depend on providers (reactive) while providers depend on services (data access), making the code testable and maintainable.

### Firebase Structure

**Authentication**: Firebase Auth with email/password
- Uses email verification (must call `sendEmailVerification()` and check `isEmailVerified`)

**Firestore Collections**:
- `patients`: Stores patient data with fields including:
  - `emergency_score` (numeric, used for sorting/prioritization)
  - Medical condition data
  - Vital signs (heart rate, respiratory rate, oxygen saturation, blood pressure)
- Patients are queried ordered by `emergency_score DESC` for triage prioritization

### Emergency Scoring System

The app uses a color-coded triage system:
- **Red** (score >= 7): Critical priority
- **Orange** (score >= 4): Urgent priority
- **Green** (score < 4): Stable/standard priority

### Medical Constants Reference

Medical conditions are mapped via ID in `lib/core/constants/medical_constants.dart`:
- Heart Attack (1), Stroke (2), Dislocated Knee (3), Kidney Stones (4)
- Appendicitis (5), Torn ACL (6), Bowel Obstruction (7), Fracture (8)
- Gallstones (9), Hernia (10)

### Navigation & Routing

Entry point: `main.dart` uses `StreamBuilder` with `FirebaseAuth.instance.authStateChanges()`
- If authenticated → Homepage (patient dashboard)
- If unauthenticated → WelcomeScreen

### UI Components

- **PatientCard** (`lib/widgets/patient_card.dart`): Reusable widget displaying patient data with color-coded emergency score
- **AppDrawer** (`lib/screens/Project/Drawer.dart`): Navigation drawer accessible from Homepage
- **FontTheme** (`lib/screens/FontTheme/fontTheme.dart`): Centralized theme configuration

### Assets
- `assets/logo.jpg`: App logo
- `assets/cat.jpg`: Placeholder/test image
- `assets/doc.webp`: Doctor-related image

## Important Implementation Notes

- Always use services (`AuthService`, `PatientService`) for Firebase operations instead of direct Firebase API calls
- Use Provider's `context.watch<AppAuthProvider>()` for reactive UI updates on auth state changes
- When adding new Firebase dependencies, update `firebase_options.dart` with proper platform configurations
- The app uses Google Fonts (Poppins, Nunito Sans) - ensure internet connectivity on first run to load fonts
- Form validation constants are centralized in `MedicalConstants` class

## Recent Improvements (Completed 2026-03-29)

### 1. Pagination Implemented
The PatientService now supports pagination to handle large datasets efficiently:
- Added `patientsStreamPaginated(limit, startAfterDocument)` for streaming paginated results
- Added `fetchPatientsNextPage(limit, startAfterDocument)` for manual fetching
- Homepage updated to use `StreamBuilder` with pagination
- Infinite scroll loads more patients as user reaches bottom of list
- Shows spinner indicator when loading more patients
- **Benefit**: App scales to hundreds/thousands of patients without performance issues

**Implementation Details:**
```dart
// In Homepage, StreamBuilder uses:
Provider.of<PatientService>(context, listen: false)
  .patientsStreamPaginated(limit: _pageSize)

// Scroll listener triggers _loadMorePatients() when near bottom
// Loading indicator shown via: itemCount = patients.length + 1
```

### 2. Test Coverage Added
Comprehensive unit tests created for core services:
- **19 unit tests** added across 2 test files
- 7 tests for PatientService (add, update, delete, get, stream)
- 12 tests for AuthService (sign in, sign up, sign out, password reset, account delete)
- Mock classes created in `test/mocks/firebase_mocks.dart` for Firebase integration

**Test Files:**
- `test/unit/patient_service_test.dart`
- `test/unit/auth_service_test.dart`
- `test/mocks/firebase_mocks.dart`

**To Run Tests:**
```bash
flutter test test/unit/patient_service_test.dart
flutter test test/unit/auth_service_test.dart
```

**Benefit**: Safety net for refactoring, catches bugs early, verifies Firebase integration works correctly

### 3. Error Handling Verified
Error handling was already well-implemented across the app:
- Already verified: AddPatient has try-catch for API calls and Firestore operations
- Already verified: LoginScreen uses SnackBars for auth errors with friendly messages
- Already verified: Homepage shows error state when Firestore fails
- **Enhanced**: Added success SnackBar when deleting patients (better user feedback)

**Error Patterns Used:**
- SnackBars for transient user-facing errors (3-5 second duration)
- try-catch blocks around all network/Firestore operations
- Conditional loading indicators (`_isLoading` flags)
- User-friendly error messages instead of technical exceptions

**Benefit**: Users see clear, actionable error messages instead of app crashes

## Next Steps / Future Enhancements

### High Priority
1. **Widget Tests** - Create widget tests for key screens:
   - `test/widget/homepage_widget_test.dart` - Test patient list, pagination, delete
   - `test/widget/login_widget_test.dart` - Test authentication flow
   - `test/widget/add_patient_widget_test.dart` - Test form validation and submission

2. **Integration Test** - Create full user journey test:
   - `integration_test/app_flow_test.dart` - Test complete flow: login → add patient → view in list → delete

3. **Offline Support** - Add local data persistence:
   - Use SQLite or Hive for local patient cache
   - Sync queue to send offline changes when connection restored
   - Critical for medical settings where internet may be unreliable

### Medium Priority
4. **Search & Filter** - Add search functionality:
   - Search patients by name, condition, or ID
   - Filter by emergency score range (critical/urgent/stable)
   - Sort by arrival time, name, or custom fields

5. **Patient History** - Track discharged/archived patients:
   - Add `discharged_at` timestamp field
   - Separate list/tab for discharged patients
   - Export functionality for reporting

6. **Enhanced Error Handling** - Add more specific handling:
   - Network error detection with retry logic
   - Permission denied errors (show admin contact info)
   - Firebase quota exceeded errors
   - Add Firebase Crashlytics for production error tracking

7. **Security & Compliance** (Critical for medical apps):
   - Role-based access control (admin, doctor, nurse permissions)
   - Audit logging (who accessed/modified patient data)
   - Session timeout for inactivity
   - HIPAA compliance audit

### Low Priority / Nice-to-Have
8. **Analytics** - Add Firebase Analytics:
   - Track user actions (login frequency, patient adds/edits)
   - Track most common medical conditions
   - Track average emergency scores by shift/time

9. **Push Notifications** - Alert healthcare staff:
   - Notify when high-priority patient (score ≥7) is added
   - Notify when patient has been waiting > 30 minutes
   - Daily/weekly summary reports

10. **Export/Reporting**:
    - Export patient list to PDF for shift handoff
    - Export to CSV for spreadsheet analysis
    - Generate automated reports for hospital management

11. **Multi-Facility Support**:
    - Add facility/location field to patients
    - Filter patients by facility
    - Support for healthcare systems with multiple locations

12. **Performance Optimizations**:
    - Add pagination to other lists (if added later)
    - Implement caching layer for frequently accessed data
    - Optimize PatientCard widget rebuilds
    - Add Debounced search (wait 300ms before searching)

13. **UI/UX Improvements**:
    - Dark mode support
    - Enhanced accessibility (screen readers, high contrast)
    - Swipe gestures for quick actions (swipe to delete)
    - Pull-to-refresh on patient list
    - Patient photos (with privacy considerations)

14. **AI/ML Enhancements**:
    - Train custom model for your facility's patient population
    - Display confidence score for emergency predictions
    - Feature importance display (which factors most affect score)

### Development Infrastructure
15. **CI/CD Pipeline**:
    - Set up GitHub Actions for automated testing
    - Automated builds for Android/iOS
    - Automated deployment to Firebase App Distribution

16. **Documentation**:
    - Create user manual for medical staff
    - Create admin guide for Firebase configuration
    - Add inline code documentation (Dart doc comments)
    - Create API documentation (if exposing API)

17. **Monitoring**:
    - Set up Firebase Performance Monitoring
    - Set up Firebase Crashlytics
    - Set up Firebase Analytics
    - Monitor app startup time, network requests, screen rendering

### Testing & Quality
18. **Increase Test Coverage**:
    - Add widget tests for all screens (aim for 80%+ coverage)
    - Add integration tests for complex user flows
    - Add screenshot tests for visual regression testing
    - Add performance tests (ensure app remains fast with many patients)

19. **Code Quality**:
    - Set up stricter linting rules in `analysis_options.yaml`
    - Add pre-commit hooks for format and analyze
    - Schedule regular code review sessions
    - Refactor any technical debt identified

## Architecture Notes for Future Development

### When Adding New Features:
1. **Create Service First** - All Firebase/HTTP operations go through services
2. **Create Provider (if needed)** - State that multiple widgets need access to
3. **Create Test** - Write test before implementing feature (TDD approach)
4. **Error Handling** - Wrap Firebase calls in try-catch, show SnackBar errors
5. **Loading States** - Always show loading indicator during async operations

### Code Organization:
- Services → Provider → Screen → Widget
- Each layer should be independently testable
- No direct Firebase calls in UI widgets (always through services)
- Follow existing patterns for consistency

### Testing Strategy:
- Unit tests: Test each service method independently (mock Firebase)
- Widget tests: Test UI interactions (mock providers)
- Integration tests: Test complete user flows (use real Firebase in staging)

### Performance Considerations:
- Use pagination for all lists (learned from Homepage optimization)
- Limit number of Stream listeners (each costs Firebase reads)
- Optimize rebuilds - use `const` constructors where possible
- Cache expensive calculations

## Deployment Checklist

Before deploying to production:
- [ ] Run all tests: `flutter test`
- [ ] Analyze code: `flutter analyze --fatal-infos`
- [ ] Build release APK: `flutter build apk --release`
- [ ] Test on physical device (not just emulator)
- [ ] Verify Firebase security rules are restrictive
- [ ] Verify API keys are in `.gitignore`
- [ ] Test offline scenario (airplane mode)
- [ ] Test with 50+ patients in list (pagination)
- [ ] Test error scenarios (Firebase down, network error)
- [ ] Verify all SnackBars appear correctly
- [ ] Check app startup time (< 3 seconds)
- [ ] Check memory usage doesn't grow unbounded

## Tips for Future Development

1. **Firebase Costs**: Monitor Firebase usage - Firestore reads/writes can get expensive. Use pagination to limit reads.

2. **Testing**: Always write tests for new features. Aim for test-first development.

3. **Emulators**: Use Firebase Emulator Suite for local development to avoid costs and enable offline work.

4. **Feature Flags**: Consider using Remote Config to enable/disable features without app update.

5. **Analytics**: Add analytics events for all user actions to understand usage patterns.

6. **Crashlytics**: Integrate Firebase Crashlytics to catch production errors.

7. **Performance**: Monitor app performance with Firebase Performance Monitoring.

8. **Security Rules**: Keep Firestore security rules minimal and tested. Test with Firebase Emulator.

9. **Data Migration**: When changing data schema, write migration scripts and tests.

10. **Documentation**: Keep CLAUDE.md updated as architecture evolves.

---

**Last Updated: 2026-03-29**
**Major Improvements**: Pagination, Comprehensive Test Coverage, Verified Error Handling

