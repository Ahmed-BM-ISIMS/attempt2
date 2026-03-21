import 'package:flutter/material.dart';
import 'doctor_sign_up_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

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
                width: 200,
                height: 200,
                child: Image.asset('assets/logo.png'),
              ),
              const SizedBox(height: 40),
              // Container wrapping the form
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
                    Container(
                      child: Column(
                        children: [
                          TextButton(onPressed: (){

                          }, child: Text('Sign up as a Doctor')),
                          Text('Sign up as a Doctor',
                          ),
                          DoctorSignUpPage(),
                        ],
                      ),
                    ),


                        ]
                      ),
                    ),
                  ],
                ),
              ),

          ),
        );

  }


}

