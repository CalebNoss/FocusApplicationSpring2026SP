import 'package:flutter/material.dart';
import 'dart:async';
import 'focus_session_screen.dart';
import '../data/session_store.dart';
import '../models/focus_session.dart';
import '../native.dart';

class TimerScreen extends StatefulWidget {
  final String experience;
  final VoidCallback? onMinimize;

  const TimerScreen({
    super.key,
    this.experience = '',
    this.onMinimize,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  int selectedMinutes = 25;
  int remainingSeconds = 25 * 60;
  int totalSeconds = 25 * 60;
  Timer? timer;

  late Timer _backgroundTimer;
  bool isRunning = false;

  late AnimationController _glowController;

  final native = NativeBindings();
  final TextEditingController customController = TextEditingController();

  // ───────────────────────── COLORS ─────────────────────────

  Color get _accentColor {
    switch (widget.experience) {
      case 'Coffeeshop':
        return const Color(0xFFB5813A);
      case 'Mountain Climb':
        return const Color(0xFF1A3A5C);
      default:
        return Colors.deepPurple.shade300;
    }
  }

  Color get _accentLight {
    switch (widget.experience) {
      case 'Coffeeshop':
        return const Color(0xFFD4A96A).withOpacity(0.3);
      case 'Mountain Climb':
        return const Color(0xFF2E6DA4).withOpacity(0.3);
      default:
        return Colors.deepPurple.shade100;
    }
  }

  // ───────────────────────── TIMER TEXT ─────────────────────────

  String get timeText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return remainingSeconds / totalSeconds;
  }

  // ───────────────────────── SESSION SAVE ─────────────────────────

  void saveCompletedSession(int minutes) {
    final updatedSessions =
        List<FocusSession>.from(focusSessionsNotifier.value);

    updatedSessions.add(
      FocusSession(
        durationMinutes: minutes,
        completedAt: DateTime.now(),
      ),
    );

    focusSessionsNotifier.value = updatedSessions;
  }

  // ───────────────────────── TIMER ─────────────────────────

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    isRunning = true;
    native.callRunStart();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();

        setState(() => remainingSeconds = 0);

        saveCompletedSession(selectedMinutes);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            title: const Text(
              'Focus Session Complete',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Great job staying focused!',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  endSession();
                },
                child: Text(
                  'Close',
                  style: TextStyle(color: _accentColor),
                ),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        remainingSeconds--;
        timerTextNotifier.value = timeText;
      });

      native.callRunMiddle();
    });
  }

  void endSession() {
    timer?.cancel();
    isRunning = false;
    native.callRunEnd();

    int completedMinutes =
        (totalSeconds - remainingSeconds) ~/ 60;

    if (completedMinutes > 0) {
      saveCompletedSession(completedMinutes);
    }

    setState(() {
      remainingSeconds = selectedMinutes * 60;
      totalSeconds = selectedMinutes * 60;
      timerTextNotifier.value = timeText;
    });
  }

  void confirmEndSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'End Focus Session?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to end your session early?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              endSession();
            },
            child: Text('Yes',
                style: TextStyle(color: _accentColor)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── INIT ─────────────────────────

  void runDistractionCheck() {
    if (isRunning) native.callRunMiddle();
  }

  @override
  void initState() {
    super.initState();

    _backgroundTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      runDistractionCheck();
    });

    // 🔥 glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    _backgroundTimer.cancel();
    _glowController.dispose();
    customController.dispose();
    super.dispose();
  }

  // ───────────────────────── UI ─────────────────────────

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'Focus Timer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (widget.onMinimize != null)
                    IconButton(
                      icon: const Icon(Icons.picture_in_picture_alt,
                          color: Colors.white70),
                      onPressed: widget.onMinimize,
                    ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Select Focus Duration',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 GLOWING CIRCLE (NEW)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(
                            0.25 + (_glowController.value * 0.2),
                          ),
                          blurRadius: 25 + (_glowController.value * 15),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: _accentLight,
                            valueColor:
                                AlwaysStoppedAnimation(_accentColor),
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
                  );
                },
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        timer != null && timer!.isActive
                            ? null
                            : startTimer,
                    child: const Text('Start Session'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: timer != null && timer!.isActive
                        ? confirmEndSession
                        : null,
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