3import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService _apiService = ApiService();
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notes = await _apiService.getAllNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNote() async {
    final newNote = Note(
      id: '', // Sera assigné par l'API
      titre: 'Nouvelle Note API',
      contenu: 'Ceci est une note créée via API REST.',
      couleur: '#FFEB3B',
      dateCreation: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création en cours...')),
    );

    try {
      final createdNote = await _apiService.createNote(newNote);
      setState(() {
        _notes.insert(0, createdNote);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note créée avec succès !')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de création de la note.')),
      );
    }
  }

  Future<void> _deleteNote(String id, int index) async {
    final note = _notes[index];
    setState(() {
      _notes.removeAt(index);
    });

    try {
      final success = await _apiService.deleteNote(id);
      if (!success) throw Exception();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note supprimée avec succès !')),
      );
    } catch (e) {
      setState(() {
        _notes.insert(index, note); // rollback
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API Distantes'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Erreur: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotes,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_notes.isEmpty) {
      return const Center(child: Text('Aucune note trouvée sur le serveur.'));
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _deleteNote(note.id, index);
          },
          child: ListTile(
            title: Text(note.titre),
            subtitle: Text(
              note.contenu,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.cloud, color: Colors.white, size: 20),
            ),
          ),
        );
      },
    );
  }
}
