import 'package:flutter/material.dart';
import 'dart:async';

import '../data/session_store.dart';
import '../models/focus_session.dart';

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

  final TextEditingController customController = TextEditingController();

  String get timeText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return remainingSeconds / totalSeconds;
  }

  void saveCompletedSession(int minutes) {
    final updatedSessions = List<FocusSession>.from(focusSessionsNotifier.value);

    updatedSessions.add(
      FocusSession(
        durationMinutes: minutes,
        completedAt: DateTime.now(),
      ),
    );

    focusSessionsNotifier.value = updatedSessions;
  }

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();

        setState(() {
          remainingSeconds = 0;
        });

        saveCompletedSession(selectedMinutes);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            title: const Text('Focus Session Complete', style: TextStyle(color: Colors.white)),
            content: const Text('Great job staying focused!', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  endSession();
                },
                child: Text('Close', style: TextStyle(color: Colors.deepPurple.shade300)),
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

  int completedMinutes = (totalSeconds - remainingSeconds) ~/ 60;

  if (completedMinutes > 0) {
    saveCompletedSession(completedMinutes);
  }

  setState(() {
    remainingSeconds = selectedMinutes * 60;
    totalSeconds = selectedMinutes * 60;
  });
  }

  void confirmEndSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('End Focus Session?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to end your session early?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              endSession();
            },
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.deepPurple.shade300),
            ),
          ),
        ],
      ),
    );
  }

  void selectDuration(int minutes) {
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      totalSeconds = minutes * 60;
    });
  }

  void setCustomTime() {
    final input = int.tryParse(customController.text);

    if (input == null || input <= 0) return;

    timer?.cancel();

    setState(() {
      selectedMinutes = input;
      remainingSeconds = input * 60;
      totalSeconds = input * 60;
    });

    customController.clear();
  }

  @override
  void dispose() {
    timer?.cancel();
    customController.dispose();
    super.dispose();
  }

  Widget durationButton(int minutes) {
    final bool isSelected = selectedMinutes == minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () => selectDuration(minutes),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple.shade300 : const Color(0xFF1C1C1E),
          foregroundColor: isSelected ? Colors.white : Colors.white70,
          side: isSelected ? null : const BorderSide(color: Colors.white24),
        ),
        child: Text('$minutes min'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
          const Text(
            'Focus Timer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          const SizedBox(height: 20),

          const Text(
            'Select Focus Duration',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              durationButton(1),
              durationButton(15),
              durationButton(25),
              durationButton(45),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Custom Duration',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: customController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Min',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1E),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: setCustomTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade300,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Set'),
              ),
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
                    color: Colors.white,
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
                onPressed:
                    timer != null && timer!.isActive ? null : startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade300,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                ),
                child: const Text('Start Session'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    timer != null && timer!.isActive
                        ? confirmEndSession
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade300,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                ),
                child: const Text('End Session'),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }
}