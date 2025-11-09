import 'package:flutter_test/flutter_test.dart';
import 'package:als_binary_keyboard/domain/services/keyboard_navigator.dart';

void main() {
  test('initial choices show 6 groups', () {
    final nav = KeyboardNavigator(letters: 'abcdef');
    final labels = nav.currentChoices;
    expect(labels.length, 6);
  });

  test('advance and select single character', () {
    final nav = KeyboardNavigator(letters: 'ab');
    // With only 2 letters split into 5 groups, first group contains 'a' as singleton
    final char = nav.advance(0);
    expect(char, 'a'); // Returns immediately since group has only 1 character
    
    final nav2 = KeyboardNavigator(letters: 'x');
    final char2 = nav2.advance(0);
    expect(char2, 'x');
  });

  test('stepBack pops stack', () {
    final nav = KeyboardNavigator(letters: 'abcdef');
    nav.advance(0); // go into first group
    expect(nav.currentChoices.length, 6);
    nav.stepBack();
    // back to root choices
    expect(nav.currentChoices.length, 6);
  });
}
