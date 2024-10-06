import 'package:hive/hive.dart';

part 'chat.g.dart';

@HiveType(typeId: 0)
class Chat extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final List<String> messages;

  Chat({
    required this.title,
    required this.id,
    required this.messages,
  });
}
