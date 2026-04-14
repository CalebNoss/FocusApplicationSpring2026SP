import 'package:flutter/material.dart';
import 'dart:async';
import 'focus_session_screen.dart';
import '../data/session_store.dart';
import '../models/focus_session.dart';
import '../native.dart';

// MUST already exist in FocusSessionScreen file
import 'focus_session_screen.dart' show timerTextNotifier;

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

  // ───────── COLORS ─────────

  Color get _accentColor {
    switch (widget.experience) {
      case 'Coffeeshop':
        return const Color(0xFFB5813A);
      case 'Mountain Climb':
        return const Color(0xFF1A3A5C);
      default:
        return Colors.black;
    }
  }

  Color get _accentLight => _accentColor.withOpacity(0.25);

  // ───────── TIMER TEXT ─────────

  String get timeText {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress =>
      totalSeconds == 0 ? 0 : remainingSeconds / totalSeconds;

  // ───────── TIMER LOGIC ─────────

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    isRunning = true;
    native.callRunStart();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();
        _endSession();
        return;
      }

      setState(() {
        remainingSeconds--;
      });

      timerTextNotifier.value = timeText; // ✅ SYNC FIX
      native.callRunMiddle();
    });
  }

  void _endSession() {
    timer?.cancel();
    isRunning = false;
    native.callRunEnd();

    final completed =
        (totalSeconds - remainingSeconds) ~/ 60;

    if (completed > 0) {
      final updated =
          List<FocusSession>.from(focusSessionsNotifier.value);

      updated.add(FocusSession(
        durationMinutes: completed,
        completedAt: DateTime.now(),
      ));

      focusSessionsNotifier.value = updated;
    }

    timerTextNotifier.value = timeText; // ✅ SYNC FIX

    Navigator.of(context).pop();
  }

  void confirmEndSession() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'End Session?',
          style: TextStyle(color: Colors.white),
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
              _endSession();
            },
            child: Text('Yes',
                style: TextStyle(color: _accentColor)),
          ),
        ],
      ),
    );
  }

  // ───────── SETTINGS ─────────

  void selectDuration(int minutes) {
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      totalSeconds = minutes * 60;
    });

    timerTextNotifier.value = timeText; // ✅ SYNC FIX
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

    timerTextNotifier.value = timeText; // ✅ SYNC FIX
    customController.clear();
  }

  void runDistractionCheck() {
    if (isRunning) native.callRunMiddle();
  }

  // ───────── INIT / DISPOSE ─────────

  @override
  void initState() {
    super.initState();

    timerTextNotifier.value = timeText; // ✅ INITIAL SYNC

    _backgroundTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      runDistractionCheck();
    });

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

  // ───────── UI ─────────

  Widget durationButton(int minutes) {
    final selected = selectedMinutes == minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () => selectDuration(minutes),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? _accentColor : const Color(0xFF1C1C1E),
          foregroundColor:
              selected ? Colors.white : Colors.white70,
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
                      icon: const Icon(
                        Icons.picture_in_picture_alt,
                        color: Colors.white70,
                      ),
                      onPressed: widget.onMinimize,
                    ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Select Focus Duration',
                style: TextStyle(color: Colors.white70),
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
                      decoration: const InputDecoration(
                        hintText: 'Min',
                        hintStyle:
                            TextStyle(color: Colors.white38),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: setCustomTime,
                    child: const Text('Set'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(
                            0.20 +
                                (_glowController.value * 0.25),
                          ),
                          blurRadius:
                              20 + (_glowController.value * 18),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 230,
                          height: 230,
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