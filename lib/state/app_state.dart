import 'package:flutter/foundation.dart';
import '../domain/entities/message.dart';
import '../domain/services/predictive_service.dart';
import '../domain/services/tts_service.dart';
import '../domain/services/keyboard_navigator.dart';
import '../domain/repositories/message_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    required PredictiveService predictiveService,
    required TtsService ttsService,
    required KeyboardNavigator keyboardNavigator,
    required MessageRepository messageRepository,
  })  : _predictiveService = predictiveService,
        _ttsService = ttsService,
        _keyboardNavigator = keyboardNavigator,
        _messageRepository = messageRepository;

  final PredictiveService _predictiveService;
  final TtsService _ttsService;
  final KeyboardNavigator _keyboardNavigator;
  final MessageRepository _messageRepository;

  String _currentText = '';
  String get currentText => _currentText;
  
  String get lastCharacter {
    if (_currentText.isEmpty) return '';
    return _currentText[_currentText.length - 1];
  }

  List<String> _predictions = const [];
  List<String> get predictions => _predictions;

  List<Message> _savedMessages = const [];
  List<Message> get savedMessages => _savedMessages;

  Future<void> initialize() async {
    await _predictiveService.loadCustomDictionary();
    _savedMessages = await _messageRepository.loadAll();
    _predictiveService.indexSavedMessages(_savedMessages.map((m) => m.text));
    _refreshPredictions();
    notifyListeners();
  }

  void onKeyInput(String input) {
    _currentText += input;
    _predictiveService.observeTypedText(_currentText);
    _refreshPredictions();
    notifyListeners();
  }

  void backspace() {
    if (_currentText.isEmpty) return;
    _currentText = _currentText.substring(0, _currentText.length - 1);
    _refreshPredictions();
    notifyListeners();
  }

  void repeatLastCharacter() {
    if (_currentText.isEmpty) return;
    final last = _currentText[_currentText.length - 1];
    _currentText += last;
    _predictiveService.observeTypedText(_currentText);
    _refreshPredictions();
    notifyListeners();
  }

  void clear() {
    _currentText = '';
    _refreshPredictions();
    notifyListeners();
  }

  Future<void> speak() async {
    await _ttsService.speak(_currentText);
  }

  Future<void> saveCurrentMessage() async {
    final message = Message(text: _currentText, createdAt: DateTime.now());
    await _messageRepository.save(message);
    _savedMessages = await _messageRepository.loadAll();
    _predictiveService.indexSavedMessages(_savedMessages.map((m) => m.text));
    notifyListeners();
  }

  void acceptPrediction(String word) {
    _currentText = _predictiveService.applyAutocomplete(_currentText, word);
    _refreshPredictions();
    notifyListeners();
  }

  void addDictionaryWordToMessage(String word) {
    if (_currentText.isEmpty) {
      _currentText = word;
    } else {
      _currentText = '$_currentText $word';
    }
    _refreshPredictions();
    notifyListeners();
  }

  List<String> get currentBinaryChoices => _keyboardNavigator.currentChoices;
  void advanceBinarySelection(int index) {
    final maybeChar = _keyboardNavigator.advance(index);
    if (maybeChar != null) {
      onKeyInput(maybeChar);
      _keyboardNavigator.reset();
    }
    notifyListeners();
  }

  void stepBackInBinarySelection() {
    _keyboardNavigator.stepBack();
    notifyListeners();
  }

  void _refreshPredictions() {
    _predictions = _predictiveService.predict(_currentText, locale: 'fr');
  }
}
