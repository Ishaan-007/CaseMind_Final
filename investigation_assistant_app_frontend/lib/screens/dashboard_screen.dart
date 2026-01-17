import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Logged in successfully 🎉',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
