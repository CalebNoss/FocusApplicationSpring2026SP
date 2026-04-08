import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import 'progress_screen.dart';
import '../widgets/audio_controls_side_panel.dart';

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
    final panelWidth =
        (MediaQuery.of(context).size.width * 0.28).clamp(280.0, 360.0);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.experience,
          style: const TextStyle(color: Colors.white),
        ),
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
                  builder: (_) => ProgressScreen(),
                ),
              );
            },
          ),
          AudioToggleButton(
            isOpen: _audioPanelOpen,
            onPressed: _toggleAudioPanel,
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
          AudioControlsSidePanel(
            isOpen: _audioPanelOpen,
            panelWidth: panelWidth,
            topPadding: 12,
          ),
        ],
      ),
    );
  }
}