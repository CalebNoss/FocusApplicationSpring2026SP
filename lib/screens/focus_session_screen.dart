import 'package:flutter/material.dart';
import 'timer_screen.dart';
import '../audio_player_widget.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

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

  void _toggleAudioPanel() {
    setState(() {
      _audioPanelOpen = !_audioPanelOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = (MediaQuery.of(context).size.width * 0.28).clamp(280.0, 360.0);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.experience, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            tooltip: 'Stats',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StatsScreen(),
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: _audioPanelOpen ? Colors.white24 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.graphic_eq, color: Colors.white),
              tooltip: 'Audio',
              onPressed: _toggleAudioPanel,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(child: TimerScreen()),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: _audioPanelOpen ? 0 : -panelWidth,
            child: Material(
              color: Colors.black,
              elevation: 18,
              child: SafeArea(
                child: SizedBox(
                  width: panelWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        const Center(
                          child: Text(
                            'Audio Controls',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Expanded(
                          child: SingleChildScrollView(
                            child: AudioPlayerWidget(),
                          ),
                        ),
                      ],
                    ),
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