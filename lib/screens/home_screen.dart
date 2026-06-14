import 'package:flutter/material.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/models/todo_item.dart';
import 'package:push_notes/navigation.dart';
import 'package:push_notes/screens/add_note_screen.dart';
import 'package:push_notes/services/note_service.dart';
import 'package:push_notes/widgets/app_bar.dart';
import 'package:push_notes/widgets/crt_route.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _noteService = NoteService();
  final Set<dynamic> _expandedKeys = {};

  @override
  void initState() {
    super.initState();
    selectedNoteKeyNotifier.addListener(_onPendingNoteKey);
    _onPendingNoteKey();
  }

  @override
  void dispose() {
    selectedNoteKeyNotifier.removeListener(_onPendingNoteKey);
    super.dispose();
  }

  void _onPendingNoteKey() {
    final key = selectedNoteKeyNotifier.value;
    if (key != null) {
      setState(() => _expandedKeys.add(key));
      selectedNoteKeyNotifier.value = null;
    }
  }

  void _confirmDelete(BuildContext ctx, Note note) {
    final messenger = ScaffoldMessenger.of(ctx);
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '~> eliminar nota?',
          style: TextStyle(fontFamily: 'monospace', color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'cancelar',
              style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'eliminar',
              style: TextStyle(fontFamily: 'monospace', color: Colors.red),
            ),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          await _noteService.deleteNote(note);
          if (ctx.mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'nota eliminada',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (ctx.mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  e.toString(),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: TopBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 16),
              child: ListenableBuilder(
                listenable: _noteService.listenable(),
                builder: (context, _) {
                  final notes = _noteService.getNotes();
                  if (notes.isEmpty) {
                    return const Center(
                      child: Text(
                        '~> sin notas',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return ListView(
                    children: notes
                        .map(
                          (note) => _NoteTile(
                            key: ValueKey(note.key),
                            note: note,
                            isExpanded: _expandedKeys.contains(note.key),
                            onTap: () => setState(() {
                              if (_expandedKeys.contains(note.key)) {
                                _expandedKeys.remove(note.key);
                              } else {
                                _expandedKeys.add(note.key);
                              }
                            }),
                            onDelete: () => _confirmDelete(context, note),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 10,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                CRTPageRoute(page: const AddNoteScreen()),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 80),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final Note note;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteTile({
    super.key,
    required this.note,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
  });

  void _toggleTodo(TodoItem todo) {
    todo.isDone = !todo.isDone;
    note.save();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ': ${note.title} >',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(note.createdAt),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (note.reminderAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_outlined, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MM-dd HH:mm').format(note.reminderAt!),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: note.reminderAt!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // description
                          Text(
                            note.description.isEmpty
                                ? 'sin descripcion'
                                : note.description,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                          if (note.todos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            // todos header
                            const Text(
                              '> todos:',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...note.todos.map(
                              (todo) => GestureDetector(
                                onTap: () => _toggleTodo(todo),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '[${todo.isDone ? 'x' : ' '}] ${todo.text}',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                      color: todo.isDone
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // actions row
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  CRTPageRoute(
                                    page: AddNoteScreen(existingNote: note),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'edit',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: onDelete,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'delete',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Colors.white,
              indent: 2,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
