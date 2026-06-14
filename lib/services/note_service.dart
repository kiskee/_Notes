import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/models/todo_item.dart';
import 'package:push_notes/services/notification_service.dart';

class NoteService {
  Box<Note> get _box => Hive.box<Note>('notes');

  Listenable listenable() => _box.listenable();

  List<Note> getNotes() {
    try {
      final notes = _box.values.toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    } catch (e) {
      throw Exception('Error al leer notas: $e');
    }
  }

  Future<void> addNote(String title, String description, {List<TodoItem>? todos, DateTime? reminderAt}) async {
    final note = Note(title: title, description: description, todos: todos, reminderAt: reminderAt);
    await _box.add(note);
    if (note.reminderAt != null) {
      try {
        await NotificationService.instance.scheduleNoteReminder(note);
      } catch (_) {}
    }
  }

  Future<void> updateNote(Note note, String title, String description, {List<TodoItem>? todos, DateTime? reminderAt}) async {
    final oldReminderAt = note.reminderAt;
    try {
      note.title = title;
      note.description = description;
      if (todos != null) note.todos = todos;
      note.reminderAt = reminderAt;
      await note.save();
    } catch (e) {
      throw Exception('Error al actualizar nota: $e');
    }
    if (oldReminderAt != null) {
      await NotificationService.instance.cancelNoteReminder(note);
    }
    if (note.reminderAt != null) {
      await NotificationService.instance.scheduleNoteReminder(note);
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      if (note.reminderAt != null) {
        await NotificationService.instance.cancelNoteReminder(note);
      }
      await note.delete();
    } catch (e) {
      throw Exception('Error al eliminar nota: $e');
    }
  }
}
