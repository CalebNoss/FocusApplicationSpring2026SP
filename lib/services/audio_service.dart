import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  AudioService._internal() {
    _player.playerStateStream.listen((state) {
      _playing = state.playing;
      notifyListeners();
    });
    _player.setVolume(_volume);
  }

  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _playing = false;
  double _volume = 0.5;
  int? _loadedIndex;
  int _currentIndex = 0;

  bool get playing => _playing;
  double get volume => _volume;
  int get currentIndex => _currentIndex;

  static const List<Map<String, String>> audios = [
    {'name': 'Thunderstorm',         'path': 'assets/audio/346768__bwav__thunder-storm-mild-raining_with_fade.mp3'},
    {'name': 'Birds in a Tree',      'path': 'assets/audio/540936__richwise__birds-in-a-tree_with_fade.mp3'},
    {'name': 'Open Window Rain',     'path': 'assets/audio/515940__lilmati__open-windows-rain-03_with_fade.mp3'},
    {'name': 'Birds and Trains',     'path': 'assets/audio/574356__lamamakesmusic__atmo_urban_wet_birds_trains_loop_with_fade.mp3'},
    {'name': 'Wind and Rain',        'path': 'assets/audio/713953__brunoauzet__wind-and-rain-at-st-brieuc_with_fade.mp3'},
    {'name': 'City Forest After Rain','path': 'assets/audio/756432__garuda1982__city-forest-after-rain-with-background-noise_with_fade.mp3'},
  ];

  Future<void> _loadCurrentAudio() async {
    await _player.setAsset(audios[_currentIndex]['path']!);
    await _player.setLoopMode(LoopMode.one);
    _loadedIndex = _currentIndex;
  }

  Future<void> togglePlay() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    if (_loadedIndex != _currentIndex || _player.audioSource == null) {
      await _loadCurrentAudio();
    }
    await _player.play();
  }

  Future<void> selectTrack(int index) async {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
    final wasPlaying = _playing;
    await _loadCurrentAudio();
    if (wasPlaying) {
      await _player.setVolume(_volume);
      await _player.play();
    }
  }

  void setVolume(double value) {
    _volume = value;
    _player.setVolume(value);
    notifyListeners();
  }
}
