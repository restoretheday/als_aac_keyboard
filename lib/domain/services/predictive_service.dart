import 'package:flutter/services.dart';

abstract class PredictiveService {
  List<String> predict(String currentText, {String locale = 'fr'});
  void observeTypedText(String text);
  void indexSavedMessages(Iterable<String> messages);
  String applyAutocomplete(String currentText, String word);
  Future<void> loadCustomDictionary();
}

class InMemoryFrenchPredictiveService implements PredictiveService {
  InMemoryFrenchPredictiveService() {
    _seed();
  }

  final Map<String, int> _frequency = <String, int>{};
  final Map<String, Map<String, int>> _nextWord = <String, Map<String, int>>{}; // word -> next word frequencies

  @override
  List<String> predict(String currentText, {String locale = 'fr'}) {
    final lastToken = _lastToken(currentText).toLowerCase();
    final suggestions = <String>[];
    final trimmedText = currentText.trimRight();
    final endsWithSpace = currentText.endsWith(' ') || trimmedText.length < currentText.length;
    
    // 1. Word completion: if typing a word (not ending with space), complete it
    if (lastToken.isNotEmpty && !endsWithSpace) {
      final completions = _frequency.keys
          .where((w) {
            // Match if the dictionary entry starts with the token
            // or if it's a multi-word entry where the first word starts with the token
            if (w.startsWith(lastToken)) return true;
            // For multi-word entries, check if first word matches
            final firstWord = w.split(' ').first.toLowerCase();
            return firstWord.startsWith(lastToken);
          })
          .toList(growable: false)
        ..sort((a, b) => (_frequency[b] ?? 0).compareTo(_frequency[a] ?? 0));
      suggestions.addAll(completions.take(5));
    }
    
    // 2. Next word prediction: suggest common next words after last complete word
    if (lastToken.isEmpty || endsWithSpace) {
      final lastCompleteWord = _lastCompleteWord(currentText).toLowerCase();
      if (lastCompleteWord.isNotEmpty && _nextWord.containsKey(lastCompleteWord)) {
        final nextWords = _nextWord[lastCompleteWord]!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        suggestions.addAll(nextWords.take(3).map((e) => e.key));
      }
      // Also suggest common sentence starters (especially if no context)
      if (lastCompleteWord.isEmpty || !_nextWord.containsKey(lastCompleteWord)) {
        suggestions.addAll(_getCommonStarters());
      }
    }
    
    // 3. Fallback: if no suggestions yet and we have a partial word, try fuzzy matching
    if (suggestions.isEmpty && lastToken.isNotEmpty && !endsWithSpace) {
      // Try to find words that contain the token as a substring (not just prefix)
      final fuzzyMatches = _frequency.keys
          .where((w) => w.contains(lastToken) && w != lastToken)
          .toList(growable: false)
        ..sort((a, b) => (_frequency[b] ?? 0).compareTo(_frequency[a] ?? 0));
      suggestions.addAll(fuzzyMatches.take(3));
    }
    
    // 4. Final fallback: always show common starters if completely empty
    if (suggestions.isEmpty) {
      suggestions.addAll(_getCommonStarters().take(5));
    }
    
    // Remove duplicates and limit
    final unique = <String>{};
    final result = <String>[];
    for (final s in suggestions) {
      if (!unique.contains(s) && s.isNotEmpty) {
        unique.add(s);
        result.add(s);
        if (result.length >= 5) break;
      }
    }
    
    return result;
  }

  @override
  void observeTypedText(String text) {
    final tokens = text.split(RegExp(r"\s+")).where((t) => t.isNotEmpty).toList();
    for (int i = 0; i < tokens.length; i++) {
      final key = tokens[i].toLowerCase();
      _frequency[key] = (_frequency[key] ?? 0) + 1;
      
      // Track next word pairs
      if (i < tokens.length - 1) {
        final nextKey = tokens[i + 1].toLowerCase();
        if (!_nextWord.containsKey(key)) {
          _nextWord[key] = <String, int>{};
        }
        _nextWord[key]![nextKey] = (_nextWord[key]![nextKey] ?? 0) + 1;
      }
    }
  }

  @override
  void indexSavedMessages(Iterable<String> messages) {
    for (final msg in messages) {
      final tokens = msg.split(RegExp(r"\s+")).where((t) => t.isNotEmpty).toList();
      for (int i = 0; i < tokens.length; i++) {
        final key = tokens[i].toLowerCase();
        _frequency[key] = (_frequency[key] ?? 0) + 2;
        
        // Track next word pairs
        if (i < tokens.length - 1) {
          final nextKey = tokens[i + 1].toLowerCase();
          if (!_nextWord.containsKey(key)) {
            _nextWord[key] = <String, int>{};
          }
          _nextWord[key]![nextKey] = (_nextWord[key]![nextKey] ?? 0) + 2;
        }
      }
    }
  }

  @override
  String applyAutocomplete(String currentText, String word) {
    final trimmed = currentText.trimRight();
    
    // If text ends with a space, we're starting a new word - just append
    if (currentText.endsWith(' ') || trimmed.length < currentText.length) {
      return trimmed.isEmpty ? '$word ' : '$trimmed $word ';
    }
    
    // Otherwise, we're completing/replacing the last incomplete word
    final parts = trimmed.split(RegExp(r"\s+"));
    if (parts.isEmpty) return '$word ';
    parts.removeLast();
    final prefix = parts.isEmpty ? '' : parts.join(' ') + ' ';
    return '$prefix$word ';
  }

  String _lastToken(String text) {
    final match = RegExp(r"([\p{L}']+)$", unicode: true).firstMatch(text);
    if (match == null) return '';
    return match.group(1) ?? '';
  }

  String _lastCompleteWord(String text) {
    final words = text.trim().split(RegExp(r"\s+"));
    if (words.isEmpty) return '';
    final last = words.last;
    // If last word looks incomplete (text ends with a space), use previous word
    if (text.trim().endsWith(' ') && words.length > 1) {
      return words[words.length - 2];
    }
    return last;
  }

  List<String> _getCommonStarters() {
    return ['je', 'tu', 'il', 'elle', 'nous', 'vous', 'bonjour', 'merci', 'oui', 'non'];
  }

  @override
  Future<void> loadCustomDictionary() async {
    try {
      final content = await rootBundle.loadString('data/custom_dictionary.txt');
      final lines = content.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      
      for (final word in lines) {
        final key = word.toLowerCase();
        // Add with higher frequency (15) so custom words are prioritized
        _frequency[key] = (_frequency[key] ?? 0) + 15;
      }
    } catch (e) {
      // If file doesn't exist or can't be loaded, continue without it
      // This allows the app to work even if the dictionary file is missing
    }
  }

  void _seed() {
    // Expanded French dictionary with common words
    const commonFrench = [
      // Pronouns
      'je','tu','il','elle','nous','vous','ils','elles','on','ça',
      // Articles
      'le','la','les','un','une','des','du','de','des',
      // Common verbs
      'être','avoir','faire','aller','venir','voir','savoir','pouvoir','vouloir','dire','parler',
      'manger','boire','dormir','rester','partir','arriver','vivre','aimer','comprendre',
      // Common nouns
      'personne','jour','nuit','matin','soir','eau','pain','maison','voiture','travail','famille',
      'ami','main','tête','corps','jardin','table','chaise','fenêtre','porte','livre',
      // Adjectives
      'bon','mauvais','grand','petit','beau','joli','nouveau','vieux','jeune','difficile','facile',
      // Adverbs
      'bien','mal','beaucoup','trop','assez','très','vite','lentement','toujours','jamais','souvent',
      // Conjunctions/prepositions
      'et','ou','mais','donc','or','ni','car','avec','sans','pour','sur','dans','par','de','à',
      // Greetings/expressions
      'bonjour','bonsoir','salut','au revoir','merci','s\'il vous plaît','de rien','oui','non',
      'comment','ça va','bien','mal','excusez-moi','pardon',
      // Time
      'aujourd\'hui','demain','hier','maintenant','bientôt','plus tard','matin','midi','soir','nuit',
      // Common phrases
      'j\'ai','tu as','il a','elle a','nous avons','vous avez','ils ont',
      'je suis','tu es','il est','elle est','nous sommes','vous êtes','ils sont',
      'je peux','tu peux','il peut','elle peut','nous pouvons','vous pouvez','ils peuvent',
      'je veux','tu veux','il veut','elle veut','nous voulons','vous voulez','ils veulent',
      'je dois','tu dois','il doit','elle doit','nous devons','vous devez','ils doivent',
    ];
    
    for (final w in commonFrench) {
      final key = w.toLowerCase();
      _frequency[key] = (_frequency[key] ?? 0) + 10;
    }
    
    // Seed common word pairs for sentence completion
    _nextWord['je'] = {'suis': 5, 'vais': 5, 'peux': 5, 'veux': 5, 'dois': 5, 'ai': 5};
    _nextWord['tu'] = {'es': 5, 'vas': 5, 'peux': 5, 'veux': 5, 'dois': 5, 'as': 5};
    _nextWord['il'] = {'est': 5, 'va': 5, 'peut': 5, 'veut': 5, 'doit': 5, 'a': 5};
    _nextWord['elle'] = {'est': 5, 'va': 5, 'peut': 5, 'veut': 5, 'doit': 5, 'a': 5};
    _nextWord['bonjour'] = {'comment': 3, 'ça': 3};
    _nextWord['merci'] = {'beaucoup': 5, 'pour': 3};
  }
}
