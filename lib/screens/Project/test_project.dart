import 'package:flutter/material.dart';
import 'package:vitasora/widgets/app_colors.dart';
import 'package:vitasora/widgets/auth_header_widget.dart';
//TODO   Flutter Formation project
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            authHeader(Title: 'Sign up', Subtitle: 'Create your account'),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: AppColors.containercolor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text('Email'),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Sign up',
                style: TextStyle(
                  color: AppColors.primary,
                 // ElevatedButton.styleFrom(overlayColor: Colors.white),
                ),
              ),),
              TextButton(
                onPressed: () {},
                child: Text('Already got an account! Sign in'),
              ),

          ],
        ),
      ),
    );
  }
}
