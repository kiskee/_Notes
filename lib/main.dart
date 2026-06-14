import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/models/todo_item.dart';
import 'package:push_notes/navigation.dart';
import 'package:push_notes/services/notification_service.dart';
import 'package:push_notes/screens/crt_splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(TodoItemAdapter());
  final box = await Hive.openBox<Note>('notes');
  tz_data.initializeTimeZones();
  await NotificationService.instance.init();
  _restoreReminders(box);
  runApp(const MyApp());
}

void _restoreReminders(Box<Note> box) {
  for (final note in box.values) {
    NotificationService.instance.restoreNoteReminder(note);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: '_notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.dark),
        textTheme: GoogleFonts.sourceCodeProTextTheme(),
      ),
      home: const CRTSplashScreen(),
    );
  }
}
