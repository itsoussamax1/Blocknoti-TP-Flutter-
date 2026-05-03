import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';
import 'detail_page.dart';
import 'api_notes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isConnected = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
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
    final noteService = context.watch<NoteService>();
    final notes = noteService.search(_query);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Mes Notes'),
            const SizedBox(width: 8),
            Consumer<NoteService>(
              builder: (context, service, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${service.count}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOption result) {
              context.read<NoteService>().setSortOption(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.dateDesc,
                child: Text('Par date (récent)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateAsc,
                child: Text('Par date (ancien)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleAsc,
                child: Text('Par titre (A \u2192 Z)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleDesc,
                child: Text('Par titre (Z \u2192 A)'),
              ),
            ],
          ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Rechercher par titre ou contenu...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty ? 'Aucune note' : 'Aucun résultat',
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];

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
                              if (context.mounted) {
                                context.read<NoteService>().deleteNote(note.id);
                              }
                            } else if (result is Note) {
                              if (context.mounted) {
                                context.read<NoteService>().updateNote(result);
                              }
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final note = await Navigator.push<Note>(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );
          if (note != null && context.mounted) {
            context.read<NoteService>().addNote(note);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
