import 'package:hive_flutter/hive_flutter.dart';
import 'package:push_notes/models/todo_item.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  List<TodoItem> todos;

  Note({
    required this.title,
    required this.description,
    DateTime? createdAt,
    List<TodoItem>? todos,
  })  : createdAt = createdAt ?? DateTime.now(),
        todos = todos ?? [];
}
