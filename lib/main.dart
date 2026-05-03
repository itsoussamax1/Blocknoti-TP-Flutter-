import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'services/note_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final noteService = NoteService(prefs);
  runApp(MyApp(noteService: noteService));
}

class MyApp extends StatelessWidget {
  final NoteService noteService;

  const MyApp({super.key, required this.noteService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-Notii',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 86, 154),
        ),
        useMaterial3: true,
      ),
      home: HomePage(noteService: noteService),
    );
  }
}
