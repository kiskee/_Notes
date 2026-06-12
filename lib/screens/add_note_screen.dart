import 'package:flutter/material.dart';
import 'package:push_notes/models/note.dart';
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

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingNote?.title ?? '');
    _descCtrl = TextEditingController(text: widget.existingNote?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingNote != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: TopBar(title: _isEditing ? '_Edit Note' : '_New Note'),
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
                      await service.updateNote(widget.existingNote!, title, desc);
                    } else {
                      await service.addNote(title, desc);
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
