import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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

  // Asset path for the rainfall audio
  final String _assetPath = 'assets/audio/7521__abinadimeza__rainfall.wav';

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      setState(() => _playing = state.playing);
    });
    _player.positionStream.listen((p) => setState(() => _position = p));
    _player.durationStream.listen((d) { if (d != null) setState(() => _duration = d); });
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
        await _player.setAsset(_assetPath);
        await _player.setLoopMode(LoopMode.one);
        await _player.play();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _duration.inMilliseconds > 0 ? _duration : Duration.zero;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _togglePlay,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              label: Text(_playing ? 'Pause' : 'Play'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async => await _player.stop(),
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (total > Duration.zero)
          Slider(
            value: _position.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
            max: total.inMilliseconds.toDouble(),
            onChanged: (v) async => await _player.seek(Duration(milliseconds: v.toInt())),
          )
        else
          Text('${_position.inSeconds}s'),
      ],
    );
  }
}
