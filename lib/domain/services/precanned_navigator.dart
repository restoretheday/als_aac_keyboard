import 'package:flutter/services.dart';

class PrecannedNavigator {
  PrecannedNavigator() {
    _rootNodes = []; // Initialize to empty list to avoid LateInitializationError
    _loadPrecannedSentences();
  }

  List<PrecannedNode> _rootNodes = [];
  final List<List<PrecannedNode>> _stack = <List<PrecannedNode>>[];

  List<String> get currentChoices {
    final groups = currentGroups;
    return groups.map(_labelForGroup).toList();
  }

  List<List<PrecannedNode>> get currentGroups {
    if (_stack.isEmpty) return _splitIntoNine(_rootNodes);
    return _splitIntoNine(_stack.last);
  }

  PrecannedResult? advance(int index) {
    final groups = currentGroups;
    if (index < 0 || index >= groups.length) return null;
    final chosen = groups[index];
    if (chosen.isEmpty) return null;
    
    // If group has multiple items, navigate into it
    if (chosen.length > 1) {
      _stack.add(chosen);
      return null;
    }
    
    final node = chosen.first;
    
    // Special cases - check both possible labels
    if (node.label == 'montrer clavier' || node.label == 'clavier') {
      return PrecannedResult(type: PrecannedResultType.showKeyboard, text: '');
    }
    if (node.label == 'phrases sauvées') {
      return PrecannedResult(type: PrecannedResultType.showSavedMessages, text: '');
    }
    
    // If it's a leaf (no children), return the full path
    if (node.children.isEmpty) {
      return PrecannedResult(
        type: PrecannedResultType.sentence,
        text: _buildFullPath(node),
      );
    }
    
    // Otherwise, navigate deeper
    _stack.add(node.children);
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

  String _buildFullPath(PrecannedNode node) {
    final parts = <String>[];
    PrecannedNode? current = node;
    while (current != null) {
      parts.insert(0, current.label);
      current = current.parent;
    }
    // Skip the root category markers (*) and return the sentence
    return parts.join(' ');
  }

  List<List<PrecannedNode>> _splitIntoNine(List<PrecannedNode> source) {
    if (source.isEmpty) return List.generate(9, (_) => <PrecannedNode>[]);
    final size = (source.length / 9).ceil();
    final groups = <List<PrecannedNode>>[];
    for (int i = 0; i < 9; i++) {
      final start = i * size;
      if (start >= source.length) {
        groups.add(<PrecannedNode>[]);
        continue;
      }
      final end = (start + size).clamp(0, source.length);
      groups.add(source.sublist(start, end));
    }
    return groups;
  }

  String _labelForGroup(List<PrecannedNode> group) {
    if (group.isEmpty) return '';
    if (group.length == 1) return group.first.label;
    // Show all labels in the group joined
    return group.map((n) => n.label).join(' ');
  }

  Future<void> _loadPrecannedSentences() async {
    try {
      final content = await rootBundle.loadString('data/precanned-sentences.txt');
      _rootNodes = _parsePrecannedFile(content);
    } catch (e) {
      _rootNodes = [];
    }
  }

  List<PrecannedNode> _parsePrecannedFile(String content) {
    final lines = content.split('\n');
    final rootNodes = <PrecannedNode>[];
    final stack = <PrecannedNode>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      final label = trimmed.replaceFirst(RegExp(r'^[*\-+]\s*'), '').trim();
      
      if (label.isEmpty) continue;
      
      // Determine depth based on marker
      PrecannedNode? parent;
      if (trimmed.startsWith('*')) {
        // Root category
        parent = null;
        final node = PrecannedNode(label: label, parent: parent);
        rootNodes.add(node);
        stack.clear();
        stack.add(node);
      } else if (trimmed.startsWith('-')) {
        // Second level
        if (stack.isNotEmpty) {
          parent = stack.first;
          final node = PrecannedNode(label: label, parent: parent);
          parent.children.add(node);
          if (stack.length > 1) stack.removeRange(1, stack.length);
          stack.add(node);
        }
      } else if (trimmed.startsWith('+')) {
        // Third level
        if (stack.length >= 2) {
          parent = stack[1];
          final node = PrecannedNode(label: label, parent: parent);
          parent.children.add(node);
          if (stack.length > 2) stack.removeRange(2, stack.length);
          stack.add(node);
        }
      }
    }
    
    return rootNodes;
  }
}

class PrecannedNode {
  PrecannedNode({required this.label, required this.parent});
  
  final String label;
  final PrecannedNode? parent;
  final List<PrecannedNode> children = [];
}

enum PrecannedResultType {
  sentence,
  showKeyboard,
  showSavedMessages,
}

class PrecannedResult {
  PrecannedResult({required this.type, required this.text});
  
  final PrecannedResultType type;
  final String text;
}

