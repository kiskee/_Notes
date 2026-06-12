import 'package:flutter/material.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/screens/add_note_screen.dart';
import 'package:push_notes/services/note_service.dart';
import 'package:push_notes/widgets/app_bar.dart';
import 'package:push_notes/widgets/crt_route.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _noteService = NoteService();
  final Set<dynamic> _expandedKeys = {};

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
            child: const Text('cancelar', style: TextStyle(fontFamily: 'monospace', color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('eliminar', style: TextStyle(fontFamily: 'monospace', color: Colors.red)),
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
                content: Text('nota eliminada', style: TextStyle(fontFamily: 'monospace')),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (ctx.mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text(e.toString(), style: const TextStyle(fontFamily: 'monospace'))),
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
                        style: TextStyle(fontFamily: 'monospace', fontSize: 24, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView(
                    children: notes.map((note) => _NoteTile(
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
                    )).toList(),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 10,
            child: GestureDetector(
              onTap: () => Navigator.push(context, CRTPageRoute(page: const AddNoteScreen())),
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
    required this.note,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
  });

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
              '~> ${note.title}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, left: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              CRTPageRoute(page: AddNoteScreen(existingNote: note)),
                            ),
                            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.description.isEmpty ? 'sin descripcion' : note.description,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
