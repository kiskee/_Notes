import 'package:hive_flutter/hive_flutter.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isDone;

  TodoItem({required this.text, this.isDone = false});
}
