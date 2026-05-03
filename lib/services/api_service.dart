import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        return Note(
          id: json['id'].toString(),
          titre: json['title'] ?? 'Sans titre',
          contenu: json['body'] ?? '',
          couleur: '#FFFFFF',
          dateCreation: DateTime.now(),
        );
      }).toList();
    } else {
      throw Exception('Erreur de chargement des notes depuis l\'API');
    }
  }

  Future<Note> createNote(Note note) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'title': note.titre,
        'body': note.contenu,
        'userId': 1,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Note(
        id: json['id'].toString(),
        titre: note.titre,
        contenu: note.contenu,
        couleur: note.couleur,
        dateCreation: note.dateCreation,
        dateModification: note.dateModification,
      );
    } else {
      throw Exception('Erreur lors de la création de la note');
    }
  }

  Future<bool> deleteNote(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
