import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Credits', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.video_library_outlined, color: Colors.white),
                  title: Text(
                    'Canva',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Video experiences (background videos)',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: Icon(Icons.link, color: Colors.white54),
                  title: Text(
                    'canva.com',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    '© Canva — used under Canva\'s Content License',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
