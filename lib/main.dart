import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:push_notes/screens/crt_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
