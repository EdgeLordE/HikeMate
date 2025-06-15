import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';
import '../Class/Mountain.dart';
import '../Class/Watchlist.dart';

class SearchMountainPage extends StatefulWidget {
  const SearchMountainPage({super.key});

  @override
  State<SearchMountainPage> createState() => _SearchMountainPageState();
}

class _SearchMountainPageState extends State<SearchMountainPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? mountainData;
  bool _isLoading = false;
  bool _isOnWatchlist = false; // Neue Statusvariable

  @override
  void initState() {
    super.initState();
    // Optional: Wenn die Seite mit einem initialen Berg geladen werden könnte,
    // müsste hier _checkIfOnWatchlist aufgerufen werden.
  }

  Future<void> _checkIfOnWatchlist() async {
    if (mountainData == null || User.id == null) {
      if (mounted) {
        setState(() {
          _isOnWatchlist = false;
        });
      }
      return;
    }
    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null || mountainIdValue is! int) {
      if (mounted) {
        setState(() {
          _isOnWatchlist = false;
        });
      }
      return;
    }

    try {
      final existingWatchlistItem = await supabase
          .from('Watchlist')
          .select('MountainID')
          .eq('UserID', User.id!)
          .eq('MountainID', mountainIdValue)
          .limit(1)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _isOnWatchlist = existingWatchlistItem != null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnWatchlist = false; // Bei Fehler auf false setzen
        });
        debugPrint('Fehler beim Überprüfen des Watchlist-Status: $e');
        // Optional eine Fehlermeldung anzeigen
      }
    }
  }

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
        _isOnWatchlist = false; // Zurücksetzen beim neuen Laden
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
            await _checkIfOnWatchlist(); // Watchlist-Status prüfen
          } else {
            setState(() {
              mountainData = null;
              _isOnWatchlist = false; // Sicherstellen, dass es false ist
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Kein Berg mit diesem Namen gefunden")),
            );
          }
        } else {
          setState(() {
            mountainData = null;
            _isOnWatchlist = false; // Sicherstellen, dass es false ist
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
          _isOnWatchlist = false; // Sicherstellen, dass es false ist
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

  Future<void> addMountainToDone() async {
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
    if (User.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benutzer nicht angemeldet.')),
        );
      }
      return;
    }

    try {
      final response = await supabase
          .from('Done')
          .select('MountainID')
          .eq('UserID', User.id!)
          .eq('MountainID', mountainIdValue)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg bereits abgehakt')),
          );
        } else {
          await supabase.from('Done').insert({
            'UserID': User.id!,
            'MountainID': mountainIdValue,
            'Date': DateTime.now().toIso8601String(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg erfolgreich abgehakt')),
          );
          // Wenn ein Berg abgehakt wird, könnte er von der Watchlist entfernt werden
          // oder zumindest der Status neu geprüft werden, falls das gewünscht ist.
          // Fürs Erste bleibt _isOnWatchlist unverändert, es sei denn, es gibt eine explizite Anforderung.
          // await _checkIfOnWatchlist(); // Optional: Watchlist-Status neu prüfen
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abhaken des Berges: $e')),
        );
      }
    }
  }

  Future<void> _toggleWatchlistStatus() async {
    if (mountainData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine Bergdaten verfügbar.')),
        );
      }
      return;
    }

    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null || mountainIdValue is! int) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gültige Berg-ID nicht in den Daten gefunden.')),
        );
      }
      return;
    }

    if (User.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benutzer nicht angemeldet.')),
        );
      }
      return;
    }

    try {
      // Prüfen, ob der Berg bereits abgehakt wurde
      final doneResponse = await supabase
          .from('Done')
          .select('MountainID')
          .eq('UserID', User.id!)
          .eq('MountainID', mountainIdValue)
          .limit(1)
          .maybeSingle();

      if (mounted && doneResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dieser Berg wurde bereits abgehakt und kann nicht zur Watchlist hinzugefügt/entfernt werden.')),
        );
        return;
      }

      if (_isOnWatchlist) {
        // Von Watchlist entfernen
        await supabase
            .from('Watchlist')
            .delete()
            .eq('UserID', User.id!)
            .eq('MountainID', mountainIdValue);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg von Watchlist entfernt')),
          );
          setState(() {
            _isOnWatchlist = false;
          });
        }
      } else {
        // Zur Watchlist hinzufügen
        final result = await Watchlist.AddToWatchlist(User.id!, mountainIdValue);
        if (mounted) {
          if (result["success"] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berg erfolgreich zur Watchlist hinzugefügt')),
            );
            setState(() {
              _isOnWatchlist = true;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result["message"] ?? 'Fehler beim Hinzufügen zur Watchlist')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler bei der Watchlist-Aktion: $e')),
        );
      }
    }
  }


  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF505050),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String federalStateName = 'Unbekannt';
    if (mountainData != null &&
        mountainData!['FederalStateid'] != null &&
        mountainData!['FederalStateid'] is Map) {
      federalStateName = mountainData!['FederalStateid']['Name'] ?? 'Unbekannt';
    }

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        fit: StackFit.expand,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent))
          else if (mountainData == null)
            const Center(
              child: Text(
                'Bitte suche nach einem Berg',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          else
            SingleChildScrollView(
              padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: isKeyboardVisible ? 16.0 : 16.0 + 80.0
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (mountainData!['Picture'] != null && mountainData!['Picture'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          mountainData!['Picture'],
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
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
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
                  ],
                ),
              ),
            ),
          if (!_isLoading && mountainData != null && !isKeyboardVisible)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: addMountainToDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Abhaken',
                        style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                          _isOnWatchlist ? Icons.favorite : Icons.favorite_border, // Geändertes Icon
                          color: Colors.white
                      ),
                      tooltip: _isOnWatchlist ? 'Von Watchlist entfernen' : 'Zur Watchlist hinzufügen', // Geänderter Tooltip
                      onPressed: _toggleWatchlistStatus, // Geänderte Funktion
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}