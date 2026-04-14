import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import 'progress_screen.dart';
import '../widgets/audio_controls_side_panel.dart';

// ── Shared notifier so the minimized pill stays in sync with the timer ────────
final timerTextNotifier = ValueNotifier<String>('25:00');

class FocusSessionScreen extends StatefulWidget {
  final String experience;

  const FocusSessionScreen({
    super.key,
    required this.experience,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  bool _audioPanelOpen = false;
  bool _timerMinimized = false;
  late final Player _player;
  late final VideoController _videoController;

  String _videoAssetForExperience(String experience) {
    switch (experience) {
      case 'Coffeeshop':
        return 'asset:///assets/videos/coffeeshop.mp4';
      case 'Mountain Climb':
        return 'asset:///assets/videos/mountainclimb.mp4';
      case 'Train Ride':
        return 'asset:///assets/videos/trainride.mp4';
      default:
        return 'asset:///assets/videos/coffeeshop.mp4';
    }
  }

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

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _player.open(Media(_videoAssetForExperience(widget.experience)));
    _player.setVolume(0);
    _player.setPlaylistMode(PlaylistMode.loop);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggleAudioPanel() =>
      setState(() => _audioPanelOpen = !_audioPanelOpen);

  @override
  Widget build(BuildContext context) {
    final panelWidth =
        (MediaQuery.of(context).size.width * 0.28).clamp(280.0, 360.0);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _timerMinimized
          ? null
          : AppBar(
              title: Text(
                widget.experience,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart, color: Colors.white),
                  tooltip: 'Stats',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProgressScreen()),
                  ),
                ),
                AudioToggleButton(
                  isOpen: _audioPanelOpen,
                  onPressed: _toggleAudioPanel,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video
          Positioned.fill(
            child: Video(
              controller: _videoController,
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.45)),

          // Full timer — hidden when minimized
          Visibility(
  visible: !_timerMinimized,
  maintainState: true,
  maintainAnimation: true,
  maintainSize: true,
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: TimerScreen(
          experience: widget.experience,
          onMinimize: () => setState(() => _timerMinimized = true),
        ),
      ),
    ),
  ),
),

          // Audio side panel — hidden when minimized
          if (!_timerMinimized)
            AudioControlsSidePanel(
              isOpen: _audioPanelOpen,
              panelWidth: panelWidth,
              topPadding: 12,
            ),

          // Minimized timer pill (top-right)
          if (_timerMinimized)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => setState(() => _timerMinimized = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: _accentColor, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: _accentColor, size: 18),
                        const SizedBox(width: 8),
                        _MinimizedTimerText(accentColor: _accentColor),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_full,
                            color: Colors.white54, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MinimizedTimerText extends StatelessWidget {
  final Color accentColor;
  const _MinimizedTimerText({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: timerTextNotifier,
      builder: (_, text, __) => Text(
        text,
        style: TextStyle(
          color: accentColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}