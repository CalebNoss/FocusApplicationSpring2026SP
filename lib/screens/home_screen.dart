import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onStartFocus;

  const HomeScreen({super.key, required this.onStartFocus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Focus App',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome back! Ready to Focus?',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onStartFocus,
            child: const Text('Start Focus Session'),
          ),
        ],
      ),
    );
  }
}
