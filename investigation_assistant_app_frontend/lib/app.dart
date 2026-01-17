import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investigation_assistant_app_frontend/screens/auth_screens.dart';
import 'package:investigation_assistant_app_frontend/screens/home_screen.dart';
import 'screens/welcome_page.dart';
import 'screens/dashboard_screen.dart'; // your main page after login

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaseMind',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/dashboard': (_) => const ActiveCasesScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const ActiveCasesScreen(); // ✅ Now has Navigator
          }

          return const WelcomePage();
        },
      ),
    );
  }
}
