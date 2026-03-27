import 'package:flutter/material.dart';
import 'package:vitasora/screens/login_screen.dart';
import 'doctor_sign_up_page.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'Welcome to VitaSora !',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Center(
                child: Image.asset('assets/logo.jpg', width: 300, height: 300),
              ),
              const SizedBox(height: 5),
              Text(
                'AI-powered emergency triage:\n'
                    'Instantly prioritizing those in greatest need',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.secondary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorSignUpPage())),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 17),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface, // White background
                  foregroundColor: colorScheme.primary, // Primary color for text
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}