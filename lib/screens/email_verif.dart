import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitasora/screens/doctor_sign_up_page.dart';
import 'package:vitasora/screens/HomePage.dart';

class EmailVerif extends StatefulWidget {
  const EmailVerif({super.key});

  @override
  State<EmailVerif> createState() => _EmailVerifState();
}

class _EmailVerifState extends State<EmailVerif> {
  bool _isLoading = false;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check every 5 seconds so the user doesn't have to tap manually
    _autoCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkEmailVerified(silent: true),
    );
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      final isVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;

      if (isVerified) {
        _autoCheckTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
        return;
      }

      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not yet verified. Please check your inbox.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking verification: $e')),
        );
      }
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DoctorSignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.all(24),
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
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verify your email',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A verification email was sent. '
                      'Please check your inbox and tap the link.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _checkEmailVerified(),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('I have verified!'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
