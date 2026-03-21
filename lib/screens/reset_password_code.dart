import 'package:flutter/material.dart';
import 'package:vitasora/screens/Reset_pass_verif.dart';

class ResetPasswordCode extends StatefulWidget {
  const ResetPasswordCode({super.key});

  @override
  State<ResetPasswordCode> createState() => _ResetPasswordCodeState();
}

class _ResetPasswordCodeState extends State<ResetPasswordCode> {
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
              const SizedBox(height: 40),
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
                child: Form(
                    child: Column(
                      children: [
                        Text(
                          'Put your verification code here',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          keyboardType: TextInputType.numberWithOptions(),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(onPressed: () {
                            Navigator.push(
                              context, MaterialPageRoute(builder: (context)=>
                            const ResetPassVerif() ),);},
                              child: const Text('Submit code')),
                        ),
                      ],
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
