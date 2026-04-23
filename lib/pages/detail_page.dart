import 'package:flutter/material.dart';
import '../models/note.dart';
import 'create_page.dart';

class DetailNotePage extends StatefulWidget {
  final Note note;
  const DetailNotePage({super.key, required this.note});

  @override
  State<DetailNotePage> createState() => _DetailNotePageState();
}

class _DetailNotePageState extends State<DetailNotePage> {
  late Note _currentNote;
  bool _wasModified = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  String _formatFrenchDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    String day = date.day.toString();
    String month = months[date.month - 1];
    String year = date.year.toString();
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year à $hour:$minute';
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    }
  }

  void _modifyNote() async {
    final dynamic modifiedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNotePage(note: _currentNote),
      ),
    );

    if (modifiedNote != null && modifiedNote is Note) {
      setState(() {
        _currentNote = modifiedNote;
        _wasModified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (didPop) return;
        Navigator.pop(context, _wasModified ? _currentNote : null);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _hexToColor(_currentNote.couleur),
          foregroundColor: Colors.black87,
          title: const Text('Détail Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _modifyNote,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentNote.titre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _formatFrenchDate(_currentNote.dateCreation),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (_currentNote.dateModification != null)
                Text(
                  'Modifiée le: ${_formatFrenchDate(_currentNote.dateModification!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              const SizedBox(height: 24),
              Text(
                _currentNote.contenu,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
