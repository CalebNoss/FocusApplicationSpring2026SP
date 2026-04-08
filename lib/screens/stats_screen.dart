import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Stats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Your focus stats will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
