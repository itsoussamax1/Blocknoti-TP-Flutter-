import 'package:flutter/material.dart';
import '../models/note.dart';

class CreateNotePage extends StatefulWidget {
  final Note? note;
  const CreateNotePage({super.key, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  final List<String> _colors = [
    '#90CAF9', // blue
    '#A5D6A7', // green
    '#FFE082', // amber
    '#FFAB91', // deepOrange
    '#CE93D8', // purple
    '#F48FB1', // pink
  ];
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.titre;
      _contentController.text = widget.note!.contenu;
      _selectedColor = widget.note!.couleur;
    } else {
      _selectedColor = _colors[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre ne peut pas être vide')),
      );
      return;
    }

    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titre: _titleController.text.trim(),
      contenu: _contentController.text.trim(),
      couleur: _selectedColor,
      dateCreation: widget.note?.dateCreation ?? DateTime.now(),
      dateModification: widget.note != null ? DateTime.now() : null,
    );

    Navigator.pop(context, note);
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nouvelle Note' : 'Modifier Note'),
        backgroundColor: _hexToColor(_selectedColor),
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Couleur:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _colors.map((colorHex) {
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorHex;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _hexToColor(colorHex),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _hexToColor(_selectedColor),
                foregroundColor: Colors.black87,
              ),
              onPressed: _saveNote,
              child: const Text('Sauvegarder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
