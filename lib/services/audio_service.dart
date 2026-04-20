import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  AudioService._internal();

  static final AudioService instance = AudioService._internal();

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool _playing = false;
  double _volume = 0.5;
  int? _loadedIndex;
  int _currentIndex = 0;

  bool get playing => _playing;
  double get volume => _volume;
  int get currentIndex => _currentIndex;

  static const List<Map<String, String>> audios = [
    {
      'name': 'Thunderstorm',
      'path':
          'assets/audio/346768__bwav__thunder-storm-mild-raining_with_fade.mp3'
    },
    {
      'name': 'Birds in a Tree',
      'path': 'assets/audio/540936__richwise__birds-in-a-tree_with_fade.mp3'
    },
    {
      'name': 'Open Window Rain',
      'path': 'assets/audio/515940__lilmati__open-windows-rain-03_with_fade.mp3'
    },
    {
      'name': 'Birds and Trains',
      'path':
          'assets/audio/574356__lamamakesmusic__atmo_urban_wet_birds_trains_loop_with_fade.mp3'
    },
    {
      'name': 'Wind and Rain',
      'path':
          'assets/audio/713953__brunoauzet__wind-and-rain-at-st-brieuc_with_fade.mp3'
    },
    {
      'name': 'City Forest After Rain',
      'path':
          'assets/audio/756432__garuda1982__city-forest-after-rain-with-background-noise_with_fade.mp3'
    },
  ];

  AudioPlayer get _activePlayer {
    if (_player != null) {
      return _player!;
    }

    final player = AudioPlayer();
    _playerStateSubscription = player.playerStateStream.listen((state) {
      _playing = state.playing;
      notifyListeners();
    });
    player.setVolume(_volume);
    _player = player;
    return player;
  }

  Future<void> _loadCurrentAudio() async {
    final player = _activePlayer;
    await player.setAsset(audios[_currentIndex]['path']!);
    await player.setLoopMode(LoopMode.one);
    _loadedIndex = _currentIndex;
  }

  Future<void> togglePlay() async {
    final player = _activePlayer;

    if (_playing) {
      await player.pause();
      return;
    }
    if (_loadedIndex != _currentIndex || player.audioSource == null) {
      await _loadCurrentAudio();
    }
    await player.play();
  }

  Future<void> selectTrack(int index) async {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
    final wasPlaying = _playing;
    await _loadCurrentAudio();
    if (wasPlaying) {
      final player = _activePlayer;
      await player.setVolume(_volume);
      await player.play();
    }
  }

  Future<void> stop() async {
    final player = _player;
    if (player == null) return;

    await player.stop();
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await player.dispose();
    _player = null;
    _loadedIndex = null;
    _playing = false;
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    _player?.setVolume(value);
    notifyListeners();
  }
}
