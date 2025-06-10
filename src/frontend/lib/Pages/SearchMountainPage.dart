import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';
import '../Class/Mountain.dart';

class SearchMountainPage extends StatefulWidget {
  const SearchMountainPage({super.key});

  @override
  State<SearchMountainPage> createState() => _SearchMountainPageState();
}

class _SearchMountainPageState extends State<SearchMountainPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? mountainData;
  bool _isLoading = false;

  Future<void> fetchMountainData(String name) async {
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bitte gib einen Bergnamen ein")),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        mountainData = null;
      });
    }

    try {
      final result = await Mountain.SearchMountainByName(name);

      if (mounted) {
        if (result["success"] == true) {
          List<dynamic> mountains = result["data"];
          if (mountains.isNotEmpty) {
            setState(() {
              mountainData = mountains.first as Map<String, dynamic>;
            });
          } else {
            setState(() {
              mountainData = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Kein Berg mit diesem Namen gefunden")),
            );
          }
        } else {
          setState(() {
            mountainData = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Fehler beim Abrufen der Bergdaten")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          mountainData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ein Fehler ist aufgetreten: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> addMountain() async {
    if (mountainData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine Bergdaten verfügbar')),
        );
      }
      return;
    }

    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg-ID nicht in den Daten gefunden.')),
        );
      }
      return;
    }

    try {
      final response = await supabase
          .from('Done')
          .select('MountainID')
          .eq('UserID', User.id)
          .eq('MountainID', mountainIdValue)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg bereits hinzugefügt')),
          );
        } else {
          await supabase.from('Done').insert({
            'UserID': User.id,
            'MountainID': mountainIdValue,
            'Date': DateTime.now().toIso8601String(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg erfolgreich hinzugefügt')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen des Berges: $e')),
        );
      }
    }
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded( // Wrap with Expanded for proper layout in Row
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF505050),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Handle long text
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String federalStateName = 'Unbekannt';
    if (mountainData != null &&
        mountainData!['FederalStateid'] != null &&
        mountainData!['FederalStateid'] is Map) {
      federalStateName = mountainData!['FederalStateid']['Name'] ?? 'Unbekannt';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF505050),
                  hintText: 'Bergname eingeben...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) => fetchMountainData(value.trim()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => fetchMountainData(_controller.text.trim()),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (mountainData == null)
            const Center(
              child: Text(
                'Bitte suche nach einem Berg',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (mountainData!['ImageURL'] != null && mountainData!['ImageURL'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          mountainData!['ImageURL'],
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.white70, size: 50),
                              ),
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.terrain, color: Colors.white70, size: 50),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      mountainData!['Name'] ?? 'Unbekannt',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoBox('Höhe', '${mountainData!['Height'] ?? 'N/A'} m'),
                        const SizedBox(width: 10),
                        _buildInfoBox('Bundesland', federalStateName),
                      ],
                    ),
                    if (mountainData!['Description'] != null && mountainData!['Description'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Beschreibung:',
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              mountainData!['Description'],
                              style: const TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 80), // Space for the button
                  ],
                ),
              ),
            ),
          if (!_isLoading && mountainData != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: addMountain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Abhacken',
                  style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}