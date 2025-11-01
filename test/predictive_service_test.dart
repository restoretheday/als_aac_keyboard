import 'package:flutter_test/flutter_test.dart';
import 'package:als_binary_keyboard/domain/services/predictive_service.dart';

void main() {
  test('predict suggests seeded French words', () {
    final svc = InMemoryFrenchPredictiveService();
    final list = svc.predict('b');
    expect(list.isNotEmpty, true);
  });

  test('applyAutocomplete replaces last token', () {
    final svc = InMemoryFrenchPredictiveService();
    final result = svc.applyAutocomplete('bonj', 'bonjour');
    expect(result, 'bonjour ');
  });

  test('indexSavedMessages boosts frequency', () {
    final svc = InMemoryFrenchPredictiveService();
    svc.indexSavedMessages(['salut salut']);
    final list = svc.predict('sa');
    expect(list.first.startsWith('sa'), true);
  });
}
