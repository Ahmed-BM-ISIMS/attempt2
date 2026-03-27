import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vitasora/core/services/auth_service.dart';
import 'package:vitasora/core/services/patient_service.dart';
import 'package:vitasora/providers/auth_provider.dart';
import 'package:vitasora/screens/HomePage.dart';
import 'package:vitasora/screens/welcome_screen.dart';

import 'firebase_options.dart';
import 'screens/FontTheme/fontTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleFonts.pendingFonts([
    GoogleFonts.poppins(),
    GoogleFonts.nunitoSans(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth service — singleton, injectable
        Provider<AuthService>(create: (_) => AuthService()),
        // Patient service — singleton, injectable
        Provider<PatientService>(create: (_) => PatientService()),
        // Reactive auth state for the whole app
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'VitaSora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme:
              GoogleFonts.nunitoSansTextTheme(ThemeData.light().textTheme)
                  .copyWith(
            displaySmall: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00A399),
            secondary: Color(0xFF12565E),
            surface: Colors.white,
          ),
        ),
        // Auth-state routing: stays on Homepage if already logged in
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }
            if (snapshot.hasData) return const Homepage();
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpg', width: 120, height: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
