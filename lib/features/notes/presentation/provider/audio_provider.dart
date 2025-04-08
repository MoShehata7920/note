import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioProvider with ChangeNotifier {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _voiceNotePath;
  bool _isAudioInitialized = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get voiceNotePath => _voiceNotePath;
  bool get isAudioInitialized => _isAudioInitialized;

  Future<void> initializeAudio() async {
    if (!_isAudioInitialized) {
      try {
        _recorder = FlutterSoundRecorder();
        _player = FlutterSoundPlayer();
        await _recorder!.openRecorder();
        await _player!.openPlayer();
        _isAudioInitialized = true;
        if (kDebugMode) print('Audio initialized');
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('Error initializing audio: $e');
      }
    }
  }

  Future<void> startRecording() async {
    await initializeAudio();
    if (_isAudioInitialized) {
      final dir = await getApplicationDocumentsDirectory();
      _voiceNotePath =
          '${dir.path}/note_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: _voiceNotePath);
      _isRecording = true;
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (_isAudioInitialized) {
      await _recorder!.stopRecorder();
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> startPlaying() async {
    await initializeAudio();
    if (_isAudioInitialized &&
        _voiceNotePath != null &&
        File(_voiceNotePath!).existsSync()) {
      await _player!.startPlayer(fromURI: _voiceNotePath);
      _isPlaying = true;
      _player!.onProgress!.listen((event) {
        if (event.position >= event.duration) {
          _isPlaying = false;
          notifyListeners();
        }
      });
      notifyListeners();
    }
  }

  Future<void> stopPlaying() async {
    if (_isAudioInitialized) {
      await _player!.stopPlayer();
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> deleteVoiceNote() async {
    if (_voiceNotePath != null && File(_voiceNotePath!).existsSync()) {
      await File(_voiceNotePath!).delete();
    }
    _voiceNotePath = null;
    notifyListeners();
  }

  void setVoiceNotePath(String? path) {
    _voiceNotePath = path;
    notifyListeners();
  }

  void disposeAudio() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    _recorder = null;
    _player = null;
    _isAudioInitialized = false;
    notifyListeners();
  }
}
