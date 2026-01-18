class KeyboardNavigator {
  KeyboardNavigator({String letters = kDefaultLetters, String specials = kDefaultSpecials})
      : _letters = letters,
        _specials = specials {
    _buildInitialGroups();
  }

  final String _letters;
  final String _specials;

  late final List<List<String>> _initialGroups;
  final List<List<String>> _stack = <List<String>>[];

  static const String kDefaultLetters = "abcdefghijklmnopqrstuvwxyz";
  static const String kDefaultSpecials = ".,?éàè"; // limited set with French accents (space removed, now has dedicated button)

  List<String> get currentChoices {
    final groups = currentGroups;
    return groups.map(_labelForGroup).toList();
  }

  List<List<String>> get currentGroups {
    if (_stack.isEmpty) return _initialGroups;
    return _splitIntoSix(_stack.last);
  }

  String? advance(int index) {
    final groups = currentGroups;
    if (index < 0 || index >= groups.length) return null;
    final chosen = groups[index];
    if (chosen.length <= 1) {
      return chosen.isEmpty ? null : chosen.first;
    }
    _stack.add(chosen);
    return null;
  }

  void stepBack() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  void reset() {
    _stack.clear();
  }

  void _buildInitialGroups() {
    final letterList = _letters.split('');
    final specialsList = _specials.split('');
    final groups = <List<String>>[];
    if (letterList.length >= 26) {
      // Standard alphabet: make last group containing uvwxyz bigger
      groups.add(letterList.sublist(0, 5)); // abcde (5 - smaller)
      groups.add(letterList.sublist(5, 10)); // fghij (5 - smaller)
      groups.add(letterList.sublist(10, 15)); // klmno (5 - smaller)
      groups.add(letterList.sublist(15, 20)); // pqrst (5 - smaller)
      groups.add(letterList.sublist(20)); // uvwxyz (6 letters - bigger)
    } else {
      // Fallback for non-standard alphabets
      final letterGroups = _splitIntoN(letterList, 5);
      groups.addAll(letterGroups);
    }
    _initialGroups = [...groups, specialsList];
  }

  static List<List<String>> _splitIntoSix(List<String> source) {
    return _splitIntoN(source, 6);
  }

  static List<List<String>> _splitIntoN(List<String> source, int n) {
    if (source.isEmpty) return List.generate(n, (_) => <String>[]);
    final size = (source.length / n).ceil();
    final groups = <List<String>>[];
    for (int i = 0; i < n; i++) {
      final start = i * size;
      if (start >= source.length) {
        groups.add(<String>[]);
        continue;
      }
      final end = (start + size).clamp(0, source.length);
      groups.add(source.sublist(start, end));
    }
    return groups;
  }

  static String _labelForGroup(List<String> group) {
    if (group.isEmpty) return '';
    if (group.length == 1) return group.first;
    // Show all characters in the group to the user
    return group.join(' ');
  }
}
