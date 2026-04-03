import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'screens/settings_screen.dart';


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

// ... rest of your existing AudioPlayerWidget code stays below
class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  double _volume = 0.5;
  int? _loadedIndex;

  final List<Map<String, String>> _audios = [
    {'name': 'Thunderstorm', 'path': 'assets/audio/346768__bwav__thunder-storm-mild-raining_with_fade.mp3'},
    {'name': 'Birds in a Tree', 'path': 'assets/audio/540936__richwise__birds-in-a-tree_with_fade.mp3'},
    {'name': 'Open Window Rain', 'path': 'assets/audio/515940__lilmati__open-windows-rain-03_with_fade.mp3'},
    {'name': 'Birds and Trains', 'path': 'assets/audio/574356__lamamakesmusic__atmo_urban_wet_birds_trains_loop_with_fade.mp3'},
    {'name': 'Wind and Rain', 'path': 'assets/audio/713953__brunoauzet__wind-and-rain-at-st-brieuc_with_fade.mp3'},
    {'name': 'City Forest After Rain', 'path': 'assets/audio/756432__garuda1982__city-forest-after-rain-with-background-noise_with_fade.mp3'},
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      setState(() => _playing = state.playing);
    });
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentAudio() async {
    await _player.setAsset(_audios[_currentIndex]['path']!);
    await _player.setLoopMode(LoopMode.one);
    _loadedIndex = _currentIndex;
  }

  Future<void> _togglePlay() async {
    try {
      if (_playing) {
        await _player.pause();
        return;
      }

      if (_loadedIndex != _currentIndex || _player.audioSource == null) {
        await _loadCurrentAudio();
      }

      await _player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio error: $e')),
      );
    }
  }

  void _onAudioChanged(String? value) {
    if (value != null) {
      int index = _audios.indexWhere((audio) => audio['name'] == value);
      if (index != -1) {
        setState(() => _currentIndex = index);
        _switchAudio();
      }
    }
  }

  Future<void> _switchAudio() async {
    bool wasPlaying = _playing;
    try {
      await _loadCurrentAudio();
      if (wasPlaying) {
        await _player.setVolume(_volume);
        await _player.play();
      }
    } catch (_) {}
  }

  void _onVolumeChanged(double value) {
    setState(() => _volume = value);
    _player.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Audio selector dropdown styled for dark background
        DropdownButton<String>(
          value: _audios[_currentIndex]['name'],
          dropdownColor: const Color(0xFF1C1C1E),
          style: const TextStyle(color: Colors.white),
          iconEnabledColor: Colors.white,
          underline: Container(height: 1, color: Colors.white24),
          items: _audios.map((audio) {
            return DropdownMenuItem<String>(
              value: audio['name'],
              child: Text(audio['name']!),
            );
          }).toList(),
          onChanged: _onAudioChanged,
        ),
        const SizedBox(height: 24),

        // Play / Pause controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _togglePlay,
              icon: Icon(
                _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
                size: 48,
              ),
              tooltip: _playing ? 'Pause' : 'Play',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Volume control
        const Text('Volume', style: TextStyle(color: Colors.white70)),
        SizedBox(
          width: 200,
          child: Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: _onVolumeChanged,
          ),
        ),
      ],
    );
  }
}