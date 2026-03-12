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
  int totalSeconds = 25 * 60;
  Timer? timer;

  String get timeText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return remainingSeconds / totalSeconds;
  }

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();

        setState(() {
          remainingSeconds = 0;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Focus Session Complete'),
            content: const Text('Great job staying focused!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  endSession();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );

        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  void endSession() {
    timer?.cancel();
    setState(() {
      remainingSeconds = selectedMinutes * 60;
      totalSeconds = selectedMinutes * 60;
    });
  }

  void selectDuration(int minutes) {
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      totalSeconds = minutes * 60;
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
          backgroundColor: isSelected ? Colors.deepPurple[300] : null,
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
          SizedBox(
            width: 230,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, animatedValue, child) {
                      return CircularProgressIndicator(
                        value: animatedValue,
                        strokeWidth: 8,
                        backgroundColor: Colors.deepPurple.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple.shade300,
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: timer != null && timer!.isActive ? null : startTimer,
                child: const Text('Start Session'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: endSession,
                child: const Text('End Session'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}