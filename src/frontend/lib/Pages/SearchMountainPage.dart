import 'package:flutter/material.dart';
import '../Class/User.dart';
import '../Class/Mountain.dart';
import '../Class/Watchlist.dart';
import '../Class/Done.dart'; // <-- REST-API für Done

/// Berg-Suchseite der HikeMate App
/// 
/// Diese Seite ermöglicht es Benutzern nach Bergen zu suchen und
/// detaillierte Informationen über gefundene Berge anzuzeigen.
/// 
/// Features:
/// - Berg-Suche nach Namen
/// - Detailansicht mit Berg-Informationen (Höhe, Koordinaten, etc.)
/// - Integration mit Watchlist (Berg als "Zu wandern" markieren)
/// - Integration mit Done-Liste (Berg als "Erledigt" markieren)
/// - Status-Anzeige (ob Berg bereits auf Watchlist oder erledigt)
class SearchMountainPage extends StatefulWidget {
  const SearchMountainPage({super.key});

  @override
  State<SearchMountainPage> createState() => _SearchMountainPageState();
}

/// State-Klasse für die SearchMountainPage mit Such- und Status-Management
class _SearchMountainPageState extends State<SearchMountainPage> {
  /// Controller für das Such-Eingabefeld
  final TextEditingController _controller = TextEditingController();
  
  /// Daten des aktuell angezeigten Berges
  Map<String, dynamic>? mountainData;
  
  /// Zeigt an ob gerade eine Suchanfrage läuft
  bool _isLoading = false;
  
  /// Status ob der Berg auf der Watchlist steht
  bool _isOnWatchlist = false;
  
  /// Status ob der Berg bereits erledigt ist
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
  }

  /// Prüft ob der aktuell angezeigte Berg auf der Watchlist steht
  /// 
  /// Aktualisiert den _isOnWatchlist Status für die UI-Anzeige
  Future<void> _checkIfOnWatchlist() async {
    if (mountainData == null || User.id == null) {
      if (mounted) setState(() => _isOnWatchlist = false);
      return;
    }
    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null || mountainIdValue is! int) {
      if (mounted) setState(() => _isOnWatchlist = false);
      return;
    }
    try {
      final result = await Watchlist.checkIfMountainIsOnWatchlist(User.id!, mountainIdValue);
      if (mounted) {
        setState(() {
          _isOnWatchlist = result["success"] == true ? (result["isOnWatchlist"] ?? false) : false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOnWatchlist = false);    }
  }

  /// Prüft ob der aktuell angezeigte Berg bereits erledigt ist
  /// 
  /// Aktualisiert den _isDone Status für die UI-Anzeige
  Future<void> _checkIfDone() async {
    if (mountainData == null || User.id == null) {
      if (mounted) setState(() => _isDone = false);
      return;
    }
    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null || mountainIdValue is! int) {
      if (mounted) setState(() => _isDone = false);
      return;
    }
    try {
      final result = await Done.isMountainDoneSimple(User.id!, mountainIdValue);
      if (mounted) setState(() => _isDone = result);
    } catch (_) {
      if (mounted) setState(() => _isDone = false);    }
  }

  /// Führt die Berg-Suche durch
  /// 
  /// [name] - Der Name des zu suchenden Berges
  /// 
  /// Diese Methode:
  /// - Validiert die Eingabe (nicht leer)
  /// - Setzt Loading-Status und resettet vorherige Daten
  /// - Führt API-Suche durch und zeigt ersten Treffer an
  /// - Prüft automatisch Watchlist- und Done-Status
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
        _isOnWatchlist = false;
        _isDone = false;
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
            await _checkIfOnWatchlist();
            await _checkIfDone();
          } else {
            setState(() {
              mountainData = null;
              _isOnWatchlist = false;
              _isDone = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Kein Berg mit diesem Namen gefunden")),
            );
          }
        } else {
          setState(() {
            mountainData = null;
            _isOnWatchlist = false;
            _isDone = false;
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
          _isOnWatchlist = false;
          _isDone = false;
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
    }  }

  /// Fügt den aktuell angezeigten Berg zu den erledigten Bergen hinzu
  /// 
  /// Diese Methode:
  /// - Validiert dass Berg-Daten vorhanden sind
  /// - Extrahiert die Berg-ID aus den Daten
  /// - Sendet eine Anfrage an das Backend
  /// - Aktualisiert den UI-Status entsprechend
  /// - Zeigt Erfolgs- oder Fehlermeldungen an
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
    if (mountainIdValue == null || mountainIdValue is! int) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg-ID nicht in den Daten gefunden oder ungültig.')),
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
      // REST-API: Prüfen ob erledigt
      final alreadyDone = await Done.isMountainDoneSimple(User.id!, mountainIdValue);
      if (mounted && alreadyDone) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg bereits abgehakt')),
        );
        setState(() => _isDone = true);
        return;
      }

      // REST-API: Berg als erledigt markieren
      final result = await Done.addMountainToDone(User.id!, mountainIdValue);
      if (mounted) {
        if (result["success"] == true) {
          setState(() => _isDone = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg erfolgreich abgehakt')),
          );
          // Wenn der Berg auf der Watchlist war, von dort entfernen (über API)
          if (_isOnWatchlist) {
            final removeResult = await Watchlist.removeMountainFromWatchlist(User.id!, mountainIdValue);
            if (removeResult["success"] == true) {
              setState(() {
                _isOnWatchlist = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Berg auch von Watchlist entfernt')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fehler beim Entfernen von der Watchlist (API): ${removeResult["message"]}')),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? 'Fehler beim Abhaken des Berges')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abhaken des Berges: $e')),
        );
      }    }
  }

  /// Wechselt den Watchlist-Status des aktuellen Berges
  /// 
  /// Diese Methode:
  /// - Fügt Berg zur Watchlist hinzu wenn er nicht drauf ist
  /// - Entfernt Berg von Watchlist wenn er drauf ist
  /// - Validiert Berg-Daten und Benutzer-Anmeldung
  /// - Aktualisiert den UI-Status entsprechend
  /// - Zeigt Feedback-Nachrichten an
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

    // REST-API: Prüfen, ob erledigt
    final alreadyDone = await Done.isMountainDoneSimple(User.id!, mountainIdValue);
    if (mounted && alreadyDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dieser Berg wurde bereits abgehakt und kann nicht zur Watchlist hinzugefügt/entfernt werden.')),
      );
      if (_isOnWatchlist) {
        setState(() {
          _isOnWatchlist = false;
        });
      }
      return;
    }

    // Watchlist-Aktionen über die Watchlist-API
    if (_isOnWatchlist) {
      final result = await Watchlist.removeMountainFromWatchlist(User.id!, mountainIdValue);
      if (mounted) {
        if (result["success"] == true) {
          setState(() {
            _isOnWatchlist = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Von Watchlist entfernt')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? 'Fehler beim Entfernen von der Watchlist')),
          );
        }
      }
    } else {
      final result = await Watchlist.addMountainToWatchlist(User.id!, mountainIdValue);
      if (mounted) {
        if (result["success"] == true) {
          setState(() {
            _isOnWatchlist = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zur Watchlist hinzugefügt')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? 'Fehler beim Hinzufügen zur Watchlist')),
          );
        }
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
                      onPressed: _isDone ? null : addMountainToDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isDone ? 'Bereits abgehakt' : 'Abhaken',
                        style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600),
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
                          _isOnWatchlist ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white
                      ),
                      tooltip: _isOnWatchlist ? 'Von Watchlist entfernen' : 'Zur Watchlist hinzufügen',
                      onPressed: _toggleWatchlistStatus,
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