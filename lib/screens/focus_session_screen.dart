import 'package:flutter/material.dart';
import 'timer_screen.dart';
import '../audio_player_widget.dart';

class FocusSessionScreen extends StatelessWidget {
  final String experience;

  const FocusSessionScreen({
    super.key,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(experience),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// AUDIO SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AudioPlayerWidget(),
            ),

            const SizedBox(height: 30),

            /// TIMER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TimerScreen(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}