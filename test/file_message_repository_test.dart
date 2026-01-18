import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:als_binary_keyboard/data/file_message_repository.dart';
import 'package:als_binary_keyboard/data/storage/local_storage.dart';
import 'package:als_binary_keyboard/domain/entities/message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Initialize SharedPreferences with empty mock data for each test
    SharedPreferences.setMockInitialValues({});
  });

  test('save and load messages', () async {
    final repo = FileMessageRepository(storage: LocalStorage('test_messages.json'));
    await repo.clearAll();
    await repo.save(Message(text: 'hello', createdAt: DateTime(2020)));
    final list = await repo.loadAll();
    expect(list.length, 1);
    expect(list.first.text, 'hello');
  });
}
