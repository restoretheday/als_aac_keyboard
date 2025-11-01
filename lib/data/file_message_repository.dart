import '../domain/entities/message.dart';
import '../domain/repositories/message_repository.dart';
import 'storage/local_storage.dart';

class FileMessageRepository implements MessageRepository {
  FileMessageRepository({LocalStorage? storage})
      : _storage = storage ?? LocalStorage('messages.json');

  final LocalStorage _storage;

  @override
  Future<List<Message>> loadAll() async {
    final json = await _storage.readJson();
    final list = (json['messages'] as List<dynamic>?) ?? <dynamic>[];
    return list
        .map((e) => Message.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<void> save(Message message) async {
    final current = await loadAll();
    final updated = [...current, message];
    await _storage.writeJson({
      'messages': updated.map((m) => m.toJson()).toList(),
    });
  }

  @override
  Future<void> clearAll() async {
    await _storage.writeJson({'messages': <Map<String, dynamic>>[]});
  }
}
