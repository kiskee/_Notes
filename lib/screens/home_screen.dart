import 'package:flutter/material.dart';
import 'package:push_notes/screens/add_note_screen.dart';
import 'package:push_notes/widgets/app_bar.dart';
import 'package:push_notes/widgets/crt_route.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: TopBar(),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NoteLine(text: '~> comprar mantequilla'),
                  _NoteLine(text: '~> llamar al dentista'),
                  _NoteLine(text: '~> pasear al perro'),
                  _NoteLine(text: '~> leer "Clean Code"'),
                  _NoteLine(text: '~> regar las plantas'),
                ],
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
