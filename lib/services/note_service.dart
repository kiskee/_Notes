import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:push_notes/models/note.dart';

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

  Future<void> addNote(String title, String description) async {
    try {
      await _box.add(Note(title: title, description: description));
    } catch (e) {
      throw Exception('Error al crear nota: $e');
    }
  }

  Future<void> updateNote(Note note, String title, String description) async {
    try {
      note.title = title;
      note.description = description;
      await note.save();
    } catch (e) {
      throw Exception('Error al actualizar nota: $e');
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await note.delete();
    } catch (e) {
      throw Exception('Error al eliminar nota: $e');
    }
  }
}
