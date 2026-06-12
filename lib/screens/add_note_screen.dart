import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:push_notes/models/note.dart';
import '../widgets/app_bar.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: TopBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  final title = _titleCtrl.text.trim();
                  final desc = _descCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('titulo requerido')),
                    );
                    return;
                  }
                  Hive.box<Note>('notes').add(Note(title: title, description: desc));
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  '~> crear nota',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
