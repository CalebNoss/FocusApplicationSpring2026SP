import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.5;
  bool _looping = true;

  final List<Map<String, String>> _audios = [
    {'name': 'Thunderstorm', 'path': 'assets/audio/346768__bwav__thunder-storm-mild-raining.mp3'},
    {'name': 'Birds in a Tree', 'path': 'assets/audio/540936__richwise__birds-in-a-tree.mp3'},
    {'name': 'Open Window Rain', 'path': 'assets/audio/515940__lilmati__open-windows-rain-03.mp3'},
    {'name': 'Birds and Trains', 'path': 'assets/audio/574356__lamamakesmusic__atmo_urban_wet_birds_trains_loop.mp3'},
    {'name': 'Wind and Rain', 'path': 'assets/audio/713953__brunoauzet__wind-and-rain-at-st-brieuc.mp3'},
    {'name': 'City Forest After Rain', 'path': 'assets/audio/756432__garuda1982__city-forest-after-rain-with-background-noise.mp3'},
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      setState(() => _playing = state.playing);
    });
    _player.positionStream.listen((p) => setState(() => _position = p));
    _player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else {
      try {
        await _player.setAsset(_audios[_currentIndex]['path']!);
        await _player.setLoopMode(_looping ? LoopMode.one : LoopMode.off);
        await _player.play();
      } catch (_) {}
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
    await _player.stop();
    if (wasPlaying) {
      try {
        await _player.setAsset(_audios[_currentIndex]['path']!);
        await _player.setLoopMode(_looping ? LoopMode.one : LoopMode.off);
        await _player.play();
      } catch (_) {}
    }
  }

  void _onVolumeChanged(double value) {
    setState(() => _volume = value);
    _player.setVolume(value);
  }

  void _toggleLoop() {
    setState(() => _looping = !_looping);
    _player.setLoopMode(_looping ? LoopMode.one : LoopMode.off);
  }

  @override
  Widget build(BuildContext context) {
    final total = _duration.inMilliseconds > 0 ? _duration : Duration.zero;

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

        // Play / Pause / Stop / Loop controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _togglePlay,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              label: Text(_playing ? 'Pause' : 'Play'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async => await _player.stop(),
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _toggleLoop,
              icon: Icon(
                _looping ? Icons.repeat_one : Icons.repeat,
                color: _looping ? Colors.greenAccent : Colors.white54,
              ),
              tooltip: _looping ? 'Disable Loop' : 'Enable Loop',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress slider
        if (total > Duration.zero)
          Slider(
            value: _position.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
            max: total.inMilliseconds.toDouble(),
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: (v) async =>
                await _player.seek(Duration(milliseconds: v.toInt())),
          )
        else
          Text(
            '${_position.inSeconds}s',
            style: const TextStyle(color: Colors.white54),
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