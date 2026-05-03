import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

enum SortOption { dateDesc, dateAsc, titleAsc, titleDesc }

class NoteService extends ChangeNotifier {
  final SharedPreferences prefs;
  static const String _notesKey = 'notes';
  List<Note> _notes = [];
  SortOption _sortOption = SortOption.dateDesc;

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
    notifyListeners();
  }

  List<Note> _getSortedNotes(List<Note> inputNotes) {
    final sorted = List<Note>.from(inputNotes);
    sorted.sort((a, b) {
      switch (_sortOption) {
        case SortOption.dateDesc:
          return b.dateCreation.compareTo(a.dateCreation);
        case SortOption.dateAsc:
          return a.dateCreation.compareTo(b.dateCreation);
        case SortOption.titleAsc:
          return a.titre.toLowerCase().compareTo(b.titre.toLowerCase());
        case SortOption.titleDesc:
          return b.titre.toLowerCase().compareTo(a.titre.toLowerCase());
      }
    });
    return sorted;
  }

  List<Note> get notes {
    return _getSortedNotes(_notes);
  }

  int get count => _notes.length;

  SortOption get sortOption => _sortOption;

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  List<Note> search(String query) {
    if (query.trim().isEmpty) {
      return notes;
    }
    final lowercaseQuery = query.toLowerCase();
    final filtered = _notes.where((note) {
      return note.titre.toLowerCase().contains(lowercaseQuery) ||
             note.contenu.toLowerCase().contains(lowercaseQuery);
    }).toList();
    return _getSortedNotes(filtered);
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
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
