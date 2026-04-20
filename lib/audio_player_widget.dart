import 'package:flutter/material.dart';
import 'screens/settings_screen.dart';
import 'services/audio_service.dart';


class AudioScreen extends StatelessWidget {
  final String title;
  const AudioScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
      body: const Center(child: AudioPlayerWidget()),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _service = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const audios = AudioService.audios;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: audios[_service.currentIndex]['name'],
          dropdownColor: const Color(0xFF1C1C1E),
          style: const TextStyle(color: Colors.white),
          iconEnabledColor: Colors.white,
          underline: Container(height: 1, color: Colors.white24),
          items: audios.map((audio) {
            return DropdownMenuItem<String>(
              value: audio['name'],
              child: Text(audio['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final index = audios.indexWhere((a) => a['name'] == value);
              if (index != -1) _service.selectTrack(index);
            }
          },
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                try {
                  await _service.togglePlay();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Audio error: $e')),
                  );
                }
              },
              icon: Icon(
                _service.playing
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: Colors.white,
                size: 48,
              ),
              tooltip: _service.playing ? 'Pause' : 'Play',
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Volume', style: TextStyle(color: Colors.white70)),
        SizedBox(
          width: 200,
          child: Slider(
            value: _service.volume,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: _service.setVolume,
          ),
        ),
      ],
    );
  }
}