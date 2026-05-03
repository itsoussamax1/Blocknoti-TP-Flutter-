import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  final SharedPreferences prefs;
  static const String _notesKey = 'notes';
  List<Note> _notes = [];

  NoteService(this.prefs) {
    _loadNotes();
  }

  void _loadNotes() {
    final notesString = prefs.getString(_notesKey);
    if (notesString != null) {
      final List<dynamic> jsonList = jsonDecode(notesString);
      _notes = jsonList.map((json) => Note.fromJson(json)).toList();
    }
  }

  Future<void> _saveNotes() async {
    final List<Map<String, dynamic>> jsonList = _notes.map((note) => note.toJson()).toList();
    await prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  List<Note> getNotes() {
    return List.from(_notes);
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveNotes();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      await _saveNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
  }
}
