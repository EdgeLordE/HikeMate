import 'package:flutter/material.dart';
import '../Class/Logging.dart';
import '../Class/User.dart';
import '../Class/Mountain.dart';
import '../Class/Watchlist.dart';
import '../Class/Done.dart';

class SearchMountainPage extends StatefulWidget {
  const SearchMountainPage({super.key});

  @override
  State<SearchMountainPage> createState() => _SearchMountainPageState();
}

class _SearchMountainPageState extends State<SearchMountainPage> {
  final _log = LoggingService();
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? mountainData;
  bool _isLoading = false;
  bool _isOnWatchlist = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _log.i('SearchMountainPage initState');
  }

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
    _log.i('Prüfe Watchlist-Status für Berg-ID: $mountainIdValue');
    try {
      final result =
      await Watchlist.checkIfMountainIsOnWatchlist(User.id!, mountainIdValue);
      if (mounted) {
        setState(() {
          _isOnWatchlist =
          result["success"] == true ? (result["isOnWatchlist"] ?? false) : false;
          _log.i('Watchlist-Status für Berg $mountainIdValue: $_isOnWatchlist');
        });
      }
    } catch (e, st) {
      _log.e('Fehler beim Prüfen des Watchlist-Status', e, st);
      if (mounted) setState(() => _isOnWatchlist = false);
    }
  }

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
    _log.i('Prüfe Done-Status für Berg-ID: $mountainIdValue');
    try {
      final result = await Done.isMountainDoneSimple(User.id!, mountainIdValue);
      if (mounted) {
        setState(() => _isDone = result);
        _log.i('Done-Status für Berg $mountainIdValue: $_isDone');
      }
    } catch (e, st) {
      _log.e('Fehler beim Prüfen des Done-Status', e, st);
      if (mounted) setState(() => _isDone = false);
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

    _log.i('Suche nach Berg: "$name"');
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
            _log.i('Berg gefunden: ${mountains.first['Name']}');
            setState(() {
              mountainData = mountains.first as Map<String, dynamic>;
            });
            await _checkIfOnWatchlist();
            await _checkIfDone();
          } else {
            _log.i('Kein Berg mit dem Namen "$name" gefunden.');
            setState(() {
              mountainData = null;
              _isOnWatchlist = false;
              _isDone = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Kein Berg mit diesem Namen gefunden")),
            );
          }
        } else {
          _log.w(
              'API-Fehler beim Abrufen der Bergdaten: ${result["message"]}');
          setState(() {
            mountainData = null;
            _isOnWatchlist = false;
            _isDone = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    result["message"] ?? "Fehler beim Abrufen der Bergdaten")),
          );
        }
      }
    } catch (e, st) {
      _log.e('Ausnahme beim Abrufen der Bergdaten', e, st);
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
    }
  }

  Future<void> addMountainToDone() async {
    if (mountainData == null || User.id == null) {
      _log.w('addMountainToDone abgebrochen: Keine Bergdaten oder Benutzer-ID.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Keine Bergdaten verfügbar oder Benutzer nicht angemeldet')),
        );
      }
      return;
    }

    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null || mountainIdValue is! int) {
      _log.w('addMountainToDone abgebrochen: Ungültige Berg-ID.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Berg-ID nicht in den Daten gefunden oder ungültig.')),
        );
      }
      return;
    }

    _log.i('Versuche, Berg $mountainIdValue als erledigt zu markieren.');
    try {
      final alreadyDone =
      await Done.isMountainDoneSimple(User.id!, mountainIdValue);
      if (mounted && alreadyDone) {
        _log.i('Berg $mountainIdValue ist bereits als erledigt markiert.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg bereits abgehakt')),
        );
        setState(() => _isDone = true);
        return;
      }

      final result = await Done.addMountainToDone(User.id!, mountainIdValue);
      if (mounted) {
        if (result["success"] == true) {
          _log.i('Berg $mountainIdValue erfolgreich als erledigt markiert.');
          setState(() => _isDone = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berg erfolgreich abgehakt')),
          );
          if (_isOnWatchlist) {
            _log.i('Berg $mountainIdValue wird von der Watchlist entfernt.');
            final removeResult = await Watchlist.removeMountainFromWatchlist(
                User.id!, mountainIdValue);
            if (removeResult["success"] == true) {
              setState(() => _isOnWatchlist = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Berg auch von Watchlist entfernt')),
              );
            } else {
              _log.w(
                  'Fehler beim Entfernen von der Watchlist: ${removeResult["message"]}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Fehler beim Entfernen von der Watchlist (API): ${removeResult["message"]}')),
              );
            }
          }
        } else {
          _log.w('Fehler beim Abhaken des Berges: ${result["message"]}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text(result["message"] ?? 'Fehler beim Abhaken des Berges')),
          );
        }
      }
    } catch (e, st) {
      _log.e('Ausnahme beim Abhaken des Berges', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abhaken des Berges: $e')),
        );
      }
    }
  }

  Future<void> _toggleWatchlistStatus() async {
    if (mountainData == null || User.id == null) {
      _log.w(
          '_toggleWatchlistStatus abgebrochen: Keine Bergdaten oder Benutzer-ID.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Keine Bergdaten verfügbar oder Benutzer nicht angemeldet.')),
        );
      }
      return;
    }

    final mountainIdValue = mountainData!['Mountainid'];
    if (mountainIdValue == null || mountainIdValue is! int) {
      _log.w('_toggleWatchlistStatus abgebrochen: Ungültige Berg-ID.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gültige Berg-ID nicht in den Daten gefunden.')),
        );
      }
      return;
    }

    _log.i('Schalte Watchlist-Status für Berg $mountainIdValue um.');
    try {
      final alreadyDone =
      await Done.isMountainDoneSimple(User.id!, mountainIdValue);
      if (mounted && alreadyDone) {
        _log.i(
            'Kann Watchlist-Status nicht ändern, da Berg $mountainIdValue bereits erledigt ist.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Dieser Berg wurde bereits abgehakt und kann nicht zur Watchlist hinzugefügt/entfernt werden.')),
        );
        if (_isOnWatchlist) {
          setState(() => _isOnWatchlist = false);
        }
        return;
      }

      if (_isOnWatchlist) {
        _log.i('Entferne Berg $mountainIdValue von der Watchlist.');
        final result = await Watchlist.removeMountainFromWatchlist(
            User.id!, mountainIdValue);
        if (mounted) {
          if (result["success"] == true) {
            setState(() => _isOnWatchlist = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Von Watchlist entfernt')),
            );
          } else {
            _log.w(
                'Fehler beim Entfernen von der Watchlist: ${result["message"]}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(result["message"] ??
                      'Fehler beim Entfernen von der Watchlist')),
            );
          }
        }
      } else {
        _log.i('Füge Berg $mountainIdValue zur Watchlist hinzu.');
        final result =
        await Watchlist.addMountainToWatchlist(User.id!, mountainIdValue);
        if (mounted) {
          if (result["success"] == true) {
            setState(() => _isOnWatchlist = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zur Watchlist hinzugefügt')),
            );
          } else {
            _log.w(
                'Fehler beim Hinzufügen zur Watchlist: ${result["message"]}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(result["message"] ??
                      'Fehler beim Hinzufügen zur Watchlist')),
            );
          }
        }
      }
    } catch (e, st) {
      _log.e('Fehler beim Umschalten des Watchlist-Status', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ein Fehler ist aufgetreten: $e')),
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
    _log.i('SearchMountainPage disposed.');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String federalStateName = 'Unbekannt';
    if (mountainData != null &&
        mountainData!['FederalStateid'] != null &&
        mountainData!['FederalStateid'] is Map) {
      federalStateName =
          mountainData!['FederalStateid']['Name'] ?? 'Unbekannt';
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
            const Center(
                child: CircularProgressIndicator(color: Colors.lightBlueAccent))
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
                  bottom: isKeyboardVisible ? 16.0 : 16.0 + 80.0),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (mountainData!['Picture'] != null &&
                        mountainData!['Picture'].isNotEmpty)
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
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white70, size: 50),
                              ),
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
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
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.lightBlueAccent),
                                  value: loadingProgress.expectedTotalBytes !=
                                      null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
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
                          child:
                          Icon(Icons.terrain, color: Colors.white70, size: 50),
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
                        _buildInfoBox(
                            'Höhe', '${mountainData!['Height'] ?? 'N/A'} m'),
                        const SizedBox(width: 10),
                        _buildInfoBox('Bundesland', federalStateName),
                      ],
                    ),
                    if (mountainData!['Description'] != null &&
                        mountainData!['Description'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Beschreibung:',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              mountainData!['Description'],
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70),
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
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
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
                          _isOnWatchlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white),
                      tooltip: _isOnWatchlist
                          ? 'Von Watchlist entfernen'
                          : 'Zur Watchlist hinzufügen',
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