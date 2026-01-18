import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<void> speak(String text);
}

class PlatformTtsService implements TtsService {
  PlatformTtsService() : _tts = FlutterTts() {
    _configureEngine();
  }

  final FlutterTts _tts;

  void _configureEngine() {
    // Android can fail silently if no engine is set; choose the default Google engine when available.
    if (!kIsWeb && Platform.isAndroid) {
      _tts.setEngine('com.google.android.tts');
      _tts.setQueueMode(1); // flush queue to avoid stacking
    }
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    await _tts.setLanguage('fr-FR');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.55);
    // Call speak but don't await completion to avoid blocking UI
    await _tts.speak(text);
  }
}
