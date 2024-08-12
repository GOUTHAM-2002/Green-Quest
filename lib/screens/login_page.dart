import 'package:flutter/material.dart';
import 'package:green_quest/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/loginScreen.png', // Replace with your image path
            fit: BoxFit.fill,

            width: double.infinity,
            height: double.infinity,
          ),
          // Centered Elevated Button
          Positioned(
            top: MediaQuery.of(context).size.height / 2, // Center vertically
            left: MediaQuery.of(context).size.width / 2 - 80, // Center horizontally
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
    foregroundColor: MaterialStateProperty.all(Colors.black),
    
    
    
              ),
              onPressed: () async {
                final userCredential =
                    await _authenticationService.signInWithGoogle();
                if (userCredential != null) {
                  // Handle successful sign-in (e.g., navigate to another page)
                  print("Signed in: ${userCredential.user?.displayName}");
                } else {
                  // Handle sign-in errors
                  print("Error signing in with Google");
                }
              },
              child: const Text("Sign in with Google!"),
            ),
          ),
        ],
      ),
    );
  }
}
