import '../entities/message.dart';

abstract class MessageRepository {
  Future<List<Message>> loadAll();
  Future<void> save(Message message);
  Future<void> delete(Message message);
  Future<void> clearAll();
}
