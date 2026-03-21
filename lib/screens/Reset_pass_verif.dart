import 'package:flutter/material.dart';
class ResetPassVerif extends StatefulWidget {
  const ResetPassVerif({super.key});

  @override
  State<ResetPassVerif> createState() => _ResetPassVerifState();
}

class _ResetPassVerifState extends State<ResetPassVerif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 250,
                width: 250,
                child: Image.asset('assets/logo.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
