import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: const Center(
        child: Text(
          "Welcome User 👋",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}