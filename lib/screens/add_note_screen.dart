import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/models/todo_item.dart';
import 'package:push_notes/services/note_service.dart';
import 'package:push_notes/widgets/app_bar.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? existingNote;
  const AddNoteScreen({super.key, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _todoCtrl;
  late List<TodoItem> _todos;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingNote?.title ?? '');
    _descCtrl = TextEditingController(text: widget.existingNote?.description ?? '');
    _todoCtrl = TextEditingController();
    _todos = [...widget.existingNote?.todos ?? []];
    _reminderAt = widget.existingNote?.reminderAt;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _todoCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingNote != null;

  void _addTodo() {
    final text = _todoCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add(TodoItem(text: text));
      _todoCtrl.clear();
    });
  }

  void _toggleTodo(TodoItem todo) {
    setState(() => todo.isDone = !todo.isDone);
  }

  void _deleteTodo(TodoItem todo) {
    setState(() => _todos.remove(todo));
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now),
    );
    if (time == null) return;
    setState(() {
      _reminderAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _clearReminder() {
    setState(() => _reminderAt = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: TopBar(title: _isEditing ? '_Edit Note' : '_New Note'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('~> titulo', style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18, color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
                hintText: 'escribe el titulo...',
                hintStyle: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('~> descripcion', style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18, color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
                hintText: 'escribe la descripcion...',
                hintStyle: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('~> todo list', style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            ..._todos.map(
              (todo) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleTodo(todo),
                      child: Text(
                        '[${todo.isDone ? 'x' : ' '}] ${todo.text}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          color: todo.isDone ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _deleteTodo(todo),
                      child: const Icon(Icons.close, size: 18, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '> ',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white),
                ),
                Expanded(
                  child: TextField(
                    controller: _todoCtrl,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white),
                    decoration: const InputDecoration.collapsed(
                      hintText: 'agregar todo...',
                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                GestureDetector(
                  onTap: _addTodo,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '+',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.green, fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('~> reminder', style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_reminderAt != null) ...[
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(_reminderAt!),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.amber),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _clearReminder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                      child: const Text(
                        'clear',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: _pickReminder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_outlined, size: 16, color: Colors.amber),
                          SizedBox(width: 6),
                          Text(
                            'set reminder',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  final title = _titleCtrl.text.trim();
                  final desc = _descCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('titulo requerido')),
                    );
                    return;
                  }
                  final service = NoteService();
                  try {
                    if (_isEditing) {
                      await service.updateNote(
                        widget.existingNote!,
                        title,
                        desc,
                        todos: _todos,
                        reminderAt: _reminderAt,
                      );
                    } else {
                      await service.addNote(
                        title,
                        desc,
                        todos: _todos,
                        reminderAt: _reminderAt,
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  _isEditing ? '~> guardar cambios' : '~> crear nota',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
