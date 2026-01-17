import 'package:flutter/material.dart';
import 'auth_screens.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.contain, // keeps full image visible
          ),
        ),
      ),
    );
  }
}
