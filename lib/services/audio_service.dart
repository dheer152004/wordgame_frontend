import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
    });
  }

  bool get isPlaying => _isPlaying;

  Future<void> playPronunciation(String audioUrl) async {
    if (audioUrl.isEmpty) {
      return;
    }

    try {
      // Stop any currently playing audio
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // Set the source and play
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
