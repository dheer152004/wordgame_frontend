import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;
  late FlutterTts _flutterTts;
  bool _isPlaying = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      // Debug log
      // ignore: avoid_print
      print(
        'AudioService: playerState changed. playing=${_isPlaying}, processingState=${state.processingState}',
      );
    });
    _audioPlayer.processingStateStream.listen((processingState) {
      // Log processing changes (buffering, completed, etc.)
      // ignore: avoid_print
      print('AudioService: processingState=$processingState');
    });
    _flutterTts = FlutterTts();
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      // ignore: avoid_print
      print('AudioService: TTS started');
    });
    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      // ignore: avoid_print
      print('AudioService: TTS completed');
    });
    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
      // ignore: avoid_print
      print('AudioService: TTS error: $msg');
    });
  }

  bool get isPlaying => _isPlaying;

  Future<void> playPronunciation(String audioUrl) async {
    // ignore: avoid_print
    print('AudioService.playPronunciation called with url: $audioUrl');

    if (audioUrl.isEmpty) {
      // ignore: avoid_print
      print('AudioService: empty audioUrl, aborting playback');
      return;
    }

    try {
      // Stop any currently playing audio
      if (_isPlaying) {
        // ignore: avoid_print
        print('AudioService: stopping currently playing audio');
        await _audioPlayer.stop();
      }

      // Set the source and play
      // ignore: avoid_print
      print('AudioService: setting url...');
      await _audioPlayer.setUrl(audioUrl);
      // ignore: avoid_print
      print('AudioService: starting playback');
      await _audioPlayer.play();
      // Listen for completion
      _audioPlayer.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          // ignore: avoid_print
          print('AudioService: playback completed');
        }
      });
    } catch (e, st) {
      // ignore: avoid_print
      print('Error playing audio: $e\n$st');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  void dispose() {
    _audioPlayer.dispose();
    try {
      _flutterTts.stop();
    } catch (_) {}
    _flutterTts.stop();
  }

  /// Speak the given [text] using device TTS (Android/iOS).
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      // ignore: avoid_print
      print('AudioService: speaking text: $text');
      await _flutterTts.speak(text);
    } catch (e, st) {
      // ignore: avoid_print
      print('AudioService: speak error: $e\n$st');
      rethrow;
    }
  }
}
