import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<void> speak(String text);
}

class IosTtsService implements TtsService {
  IosTtsService() : _tts = FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.setLanguage('fr-FR');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }
}
