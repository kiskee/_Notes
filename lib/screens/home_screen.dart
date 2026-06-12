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
                    return Center(
                      child: const Text(
                        '~> sin notas',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 24, color: Colors.grey),
                      ),
                    );
                  }
                  notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return ListView(
                    children: notes.map((note) => _NoteLine(text: '~> ${note.title}')).toList(),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 40,
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

class _NoteLine extends StatelessWidget {
  final String text;
  const _NoteLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
