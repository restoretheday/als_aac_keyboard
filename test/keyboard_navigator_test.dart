import 'package:flutter_test/flutter_test.dart';
import 'package:als_binary_keyboard/domain/services/keyboard_navigator.dart';

void main() {
  test('initial choices show 6 groups', () {
    final nav = KeyboardNavigator(characterSet: 'abcdef');
    final labels = nav.currentChoices;
    expect(labels.length, 6);
  });

  test('advance and select single character', () {
    final nav = KeyboardNavigator(characterSet: 'ab');
    expect(nav.advance(0), isNull); // first group contains 'a'
    // since size ceil(2/6)=1, groups will be mostly singletons; stepping again
    nav.reset();
    final nav2 = KeyboardNavigator(characterSet: 'x');
    final char = nav2.advance(0);
    expect(char, 'x');
  });

  test('stepBack pops stack', () {
    final nav = KeyboardNavigator(characterSet: 'abcdef');
    nav.advance(0); // go into first group
    expect(nav.currentChoices.length, 6);
    nav.stepBack();
    // back to root choices
    expect(nav.currentChoices.length, 6);
  });
}
