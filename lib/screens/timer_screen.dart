import 'package:flutter/material.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int selectedMinutes = 25;
  int remainingSeconds = 25 * 60;
  Timer? timer;

  String get timeText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() {
        remainingSeconds--;
      });
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = selectedMinutes * 60;
    });
  }

  void selectDuration(int minutes) {
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget durationButton(int minutes) {
    final bool isSelected = selectedMinutes == minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () => selectDuration(minutes),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple[200] : null,
        ),
        child: Text('$minutes min'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Focus Timer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Focus Duration',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              durationButton(15),
              durationButton(25),
              durationButton(45),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.deepPurple.shade200,
                width: 8,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              timeText,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: timer != null && timer!.isActive ? null : startTimer,
                child: const Text('Start'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: resetTimer,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}