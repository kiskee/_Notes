import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/screens/add_note_screen.dart';
import 'package:push_notes/widgets/app_bar.dart';
import 'package:push_notes/widgets/crt_route.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Box<Note> _notesBox;
  final Set<dynamic> _expandedKeys = {};

  @override
  void initState() {
    super.initState();
    _notesBox = Hive.box<Note>('notes');
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
              child: ValueListenableBuilder(
                valueListenable: _notesBox.listenable(),
                builder: (context, Box<Note> box, _) {
                  final notes = box.values.toList();
                  if (notes.isEmpty) {
                    return const Center(
                      child: Text(
                        '~> sin notas',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 24, color: Colors.grey),
                      ),
                    );
                  }
                  notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  const _NoteTile({
    required this.note,
    required this.isExpanded,
    required this.onTap,
  });

  void _confirmDelete(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
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
    ).then((confirmed) {
      if (confirmed == true) {
        note.delete();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('nota eliminada', style: TextStyle(fontFamily: 'monospace')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
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
                            onPressed: () => _confirmDelete(context),
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
