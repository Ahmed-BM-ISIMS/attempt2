import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // ========== Color Scheme ==========
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF00B4A3),       // Primary buttons
          onPrimary: Colors.white,                // Text on buttons
          primaryContainer: const Color(0xFF0A5C6B), // AppBar
          onPrimaryContainer: Colors.white,       // AppBar text
          surface: const Color(0xFFF5FDFF),       // Scaffold background
          secondary: const Color(0xFF4DD0E1),     // Secondary elements
          onSurface: Colors.black87,              // Default text color
          surfaceContainerHighest: const Color(0xFFE6F7F4), // Cards/containers
        ),

        // ========== Text Theme ==========
        textTheme: GoogleFonts.nunitoSansTextTheme().copyWith(
          // Headings (Poppins)
          displayLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: const Color(0xFF0C4047),
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),

          // Body Text (Nunito Sans)
          bodyLarge: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),

          // Buttons (Manrope)
          labelLarge: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        // ========== Component Themes ==========
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A5C6B),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),


        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4A3),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
        ),);
    }
}