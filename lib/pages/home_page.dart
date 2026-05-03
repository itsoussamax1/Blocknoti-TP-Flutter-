import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';
import 'detail_page.dart';
import 'api_notes_page.dart';

class HomePage extends StatefulWidget {
  final NoteService noteService;

  const HomePage({super.key, required this.noteService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (!mounted) return;
      setState(() {
        _isConnected = result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.ethernet);
      });
    });
  }

  void _loadNotes() {
    setState(() {
      _notes = widget.noteService.getNotes();
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!mounted) return;
    setState(() {
      _isConnected = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_sync : Icons.cloud_off,
              color: _isConnected ? Colors.white : Colors.redAccent,
            ),
            onPressed: () {
              if (_isConnected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApiNotesPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aucune connexion Internet. Synchronisation impossible.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text('Aucune note', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];

                String previewContenu = note.contenu.replaceAll('\n', ' ');
                if (previewContenu.length > 30) {
                  previewContenu = '${previewContenu.substring(0, 30)}...';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNotePage(note: note),
                        ),
                      );

                      if (result == 'deleted') {
                        await widget.noteService.deleteNote(note.id);
                        _loadNotes();
                      } else if (result is Note) {
                        await widget.noteService.updateNote(result);
                        _loadNotes();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: _hexToColor(note.couleur),
                            width: 8,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.titre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(previewContenu),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(note.dateCreation),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final note = await Navigator.push<Note>(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );
          if (note != null) {
            await widget.noteService.addNote(note);
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
