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
          const Icon(
            Icons.timer_outlined,
            size: 70,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 24),

          const Text(
            'Focus App',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Stay productive and distraction-free',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: onStartFocus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Start Focus Session',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}