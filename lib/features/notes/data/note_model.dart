import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  bool isPinned;

  @HiveField(5)
  String? category;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.isPinned = false,
    this.category,
  });
}