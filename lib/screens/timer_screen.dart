import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'focus_session_screen.dart' show timerTextNotifier;
import '../data/session_store.dart';
import '../models/focus_session.dart';
import '../native.dart';
import '../services/audio_service.dart';

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
  State<TimerScreen> createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  // Blocking is enabled, but native checks are throttled to reduce UI jank.
  static const bool _enableNativeBlocking = true;
  static const Duration _nativeCheckInterval = Duration(seconds: 4);

  int selectedMinutes = 25;
  int remainingSeconds = 25 * 60;
  int totalSeconds = 25 * 60;

  Timer? timer;
  Timer? _nativeCheckTimer;
  bool isRunning = false;
  bool _nativeSessionActive = false;

  NativeBindings? _native;
  final TextEditingController customController = TextEditingController();
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier(25 * 60);
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _glowController;

  static String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setRemainingSeconds(int value) {
    remainingSeconds = value;
    _remainingSecondsNotifier.value = value;
    timerTextNotifier.value = _formatTime(value);
  }

  void _ensureNativeBindings() {
    _native ??= NativeBindings();
  }

  void _startNativeBlocking() {
    if (!_enableNativeBlocking) return;

    _ensureNativeBindings();
    _nativeSessionActive = true;

    Future<void>.delayed(
      const Duration(milliseconds: 200),
      () {
        if (!isRunning || !_nativeSessionActive) return;
        _native?.callRunStart();
      },
    );

    _nativeCheckTimer?.cancel();
    _nativeCheckTimer = Timer.periodic(_nativeCheckInterval, (_) {
      if (!isRunning || !_nativeSessionActive) return;
      Future<void>.delayed(
        Duration.zero,
        () => _native?.callRunMiddle(),
      );
    });
  }

  void _stopNativeBlocking() {
    if (!_enableNativeBlocking) return;

    _nativeCheckTimer?.cancel();
    _nativeCheckTimer = null;

    if (!_nativeSessionActive) return;
    _nativeSessionActive = false;

    Future<void>.delayed(
      Duration.zero,
      () => _native?.callRunEnd(),
    );
  }

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

  Color get _accentLight => _accentColor.withValues(alpha: 0.25);

  String get timeText => _formatTime(remainingSeconds);

  Future<void> _playCompletionSound() async {
    await _player.setAsset('assets/audio/FocusAppSuccess.wav');
    _player.play();
  }
  
  // ───────── START TIMER ─────────

  void startTimer() {
    if (timer != null && timer!.isActive) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();
        _completeSession();
        return;
      }

      _setRemainingSeconds(remainingSeconds - 1);
    });

    try {
      _startNativeBlocking();
    } catch (_) {}
  }

  // ───────── NATURAL COMPLETION ─────────

  Future<void> _completeSession() async {
    _stopSessionRuntime();
    _stopNativeBlocking();
    await AudioService.instance.stop();
    _recordCompletedSession(totalSeconds ~/ 60);

    _setRemainingSeconds(0);

    _playCompletionSound();
    
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          "Session Complete",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Great work. Your focus session has been saved.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }

  // ───────── MANUAL END ─────────

  Future<void> _endSession() async {
    _stopSessionRuntime();
    _stopNativeBlocking();
    await AudioService.instance.stop();
    _recordCompletedSession((totalSeconds - remainingSeconds) ~/ 60);
    Navigator.of(context).pop();
  }

  void _stopSessionRuntime() {
    timer?.cancel();
    if (!mounted) {
      isRunning = false;
      return;
    }

    setState(() {
      isRunning = false;
    });
  }

  void _recordCompletedSession(int minutes) {
    if (minutes <= 0) return;

    final updated = List<FocusSession>.from(focusSessionsNotifier.value);
    updated.add(FocusSession(
      durationMinutes: minutes,
      completedAt: DateTime.now(),
    ));
    focusSessionsNotifier.value = updated;
  }

  void confirmEndSession() {
    if (!(timer?.isActive ?? false) || !isRunning) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title:
            const Text('End Session?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _endSession();
            },
            child: Text('Yes', style: TextStyle(color: _accentColor)),
          ),
        ],
      ),
    );
  }

  void selectDuration(int minutes) {
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      totalSeconds = minutes * 60;
    });

    _setRemainingSeconds(minutes * 60);
  }

  void setCustomTime() {
    final input = int.tryParse(customController.text);
    if (input == null || input <= 0) return;

    timer?.cancel();
    setState(() {
      selectedMinutes = input;
      totalSeconds = input * 60;
    });

    _setRemainingSeconds(input * 60);
    customController.clear();
  }

  @override
  void initState() {
    super.initState();
    _setRemainingSeconds(remainingSeconds);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    _stopNativeBlocking();
    _glowController.dispose();
    _remainingSecondsNotifier.dispose();
    customController.dispose();
    _player.dispose();
    super.dispose();
  }

  Widget durationButton(int minutes) {
    final selected = selectedMinutes == minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () => selectDuration(minutes),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? _accentColor : const Color(0xFF1C1C1E),
          foregroundColor: selected ? Colors.white : Colors.white70,
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
                        hintStyle: TextStyle(color: Colors.white38),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
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
              ValueListenableBuilder<int>(
                valueListenable: _remainingSecondsNotifier,
                builder: (_, seconds, __) {
                  final currentProgress =
                      totalSeconds == 0 ? 0.0 : seconds / totalSeconds;

                  return AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, __) => Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.30),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withValues(
                              alpha: 0.20 + (_glowController.value * 0.25),
                            ),
                            blurRadius: 20 + (_glowController.value * 18),
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
                              value: currentProgress,
                              strokeWidth: 8,
                              backgroundColor: _accentLight,
                              valueColor: AlwaysStoppedAnimation(_accentColor),
                            ),
                          ),
                          Text(
                            _formatTime(seconds),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? null : startTimer,
                    child: const Text('Start Session'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isRunning ? confirmEndSession : null,
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
