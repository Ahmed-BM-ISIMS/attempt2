import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:vitasora/screens/welcome_screen.dart';

import 'firebase_options.dart';
import 'screens/FontTheme/fontTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Optional: Preload fonts (recommended)
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
    return MaterialApp(
      title: 'VitaSora',
      debugShowCheckedModeBanner: false,

      // ===== THEME CONFIGURATION =====
      theme: AppTheme.lightTheme.copyWith(
        // Ensure these exist in your AppTheme
        textTheme: GoogleFonts.nunitoSansTextTheme(ThemeData.light().textTheme)
            .copyWith(
              displaySmall: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

        colorScheme: ColorScheme.light(
          primary: const Color(0xFF00A399),
          secondary: const Color(0xFF12565E),
          surface: Colors.white,
        ),
      ),

      home: const WelcomeScreen(),
    );
  }
}
