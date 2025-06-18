import 'dart:async';
import 'package:flutter/material.dart';
import '../Class/Logging.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';
import '../Class/Watchlist.dart';
import '../Class/Done.dart';

class DonePage extends StatefulWidget {
  const DonePage({Key? key}) : super(key: key);

  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage>
    with SingleTickerProviderStateMixin {
  final _log = LoggingService();
  late TabController _tabController;
  List<Map<String, dynamic>> _doneList = [];
  List<Map<String, dynamic>> _watchlist = [];
  bool _isLoading = false;

  String _searchQuery = '';
  String _filterState = 'Alle';
  List<String> get _availableStates {
    final states = <String>{'Alle'};
    for (var item in _doneList) {
      if (item['Mountain'] != null && item['Mountain']['FederalState'] != null && item['Mountain']['FederalState']['Name'] != null) {
        states.add(item['Mountain']['FederalState']['Name']);
      }
    }
    for (var item in _watchlist) {
      if (item['Mountain'] != null && item['Mountain']['FederalState'] != null && item['Mountain']['FederalState']['Name'] != null) {
        states.add(item['Mountain']['FederalState']['Name']);
      }
    }
    final sortedStates = states.toList();
    if (sortedStates.length > 1 && sortedStates[0] == 'Alle') {
      final otherStates = sortedStates.sublist(1)..sort();
      return ['Alle'] + otherStates;
    }
    return sortedStates..sort();
  }
  String _sortMode = 'Neu → Alt';

  List<Map<String, dynamic>> get _filteredDone {
    var list = _doneList.where((e) {
      final name = (e['Mountain']?['Name'] as String?)?.toLowerCase() ?? '';
      final state = (e['Mountain']?['FederalState']?['Name'] as String?) ?? '';
      return name.contains(_searchQuery.toLowerCase()) &&
          (_filterState == 'Alle' || state == _filterState);
    }).toList();

    switch (_sortMode) {
      case 'Alt → Neu':
        list.sort((a, b) =>
            DateTime.parse(a['Date']).compareTo(DateTime.parse(b['Date'])));
        break;
      case 'A → Z':
        list.sort((a, b) =>
            (a['Mountain']?['Name'] as String? ?? '')
                .compareTo(b['Mountain']?['Name'] as String? ?? ''));
        break;
      case 'Z → A':
        list.sort((a, b) =>
            (b['Mountain']?['Name'] as String? ?? '')
                .compareTo(a['Mountain']?['Name'] as String? ?? ''));
        break;
      case 'Neu → Alt':
      default:
        list.sort((a, b) =>
            DateTime.parse(b['Date']).compareTo(DateTime.parse(a['Date'])));
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredWatchlist {
    var list = _watchlist.where((e) {
      final name = (e['Mountain']?['Name'] as String?)?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    list.sort((a, b) =>
        (a['Mountain']?['Name'] as String? ?? '').compareTo(b['Mountain']?['Name'] as String? ?? ''));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _log.i('DonePage initState');
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        _log.i('Tab gewechselt, Suchanfrage wird zurückgesetzt.');
        setState(() {
          _searchQuery = '';
        });
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    _log.i('Lade Done- und Watchlist-Daten...');
    if (mounted) setState(() => _isLoading = true);
    await Future.wait([_fetchDone(), _fetchWatchlist()]);
    if (mounted) setState(() => _isLoading = false);
    _log.i('Daten erfolgreich geladen.');
  }

  Future<void> _fetchDone() async {
    _log.i('Rufe Done-Liste ab...');
    try {
      final result = await Done.fetchDoneList(User.id);
      if (mounted) {
        if (result["success"] == true && result["data"] is List) {
          _doneList = List<Map<String, dynamic>>.from(result["data"]);
          _log.i('Done-Liste erfolgreich abgerufen: ${_doneList.length} Einträge.');
        } else {
          _log.w('Fehler beim Abrufen der Done-Liste: ${result["message"]}');
          _doneList = [];
        }
      }
    } catch (e, st) {
      _log.e('Ausnahme beim Abrufen der Done-Liste', e, st);
      if (mounted) _doneList = [];
    }
  }

  Future<void> _fetchWatchlist() async {
    _log.i('Rufe Watchlist ab...');
    try {
      final result = await Watchlist.fetchWatchlist(User.id);
      if (mounted) {
        if (result["success"] == true && result["data"] is List) {
          _watchlist = List<Map<String, dynamic>>.from(result["data"]);
          _log.i('Watchlist erfolgreich abgerufen: ${_watchlist.length} Einträge.');
        } else {
          _log.w('Fehler beim Abrufen der Watchlist: ${result["message"]}');
          _watchlist = [];
        }
      }
    } catch (e, st) {
      _log.e('Ausnahme beim Abrufen der Watchlist', e, st);
      if (mounted) _watchlist = [];
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _deleteDone(int id) async {
    _log.i('Lösche Done-Eintrag mit ID: $id');
    try {
      final result = await Done.deleteDone(id, User.id);
      if (mounted) {
        if (result["success"] == true) {
          _log.i('Done-Eintrag erfolgreich gelöscht.');
          setState(() => _doneList.removeWhere((e) => e['DoneID'] == id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eintrag gelöscht'), backgroundColor: Colors.redAccent),
          );
        } else {
          _log.e('Fehler beim Löschen des Done-Eintrags: ${result["message"]}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Löschen: ${result["message"] ?? ""}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e, st) {
      _log.e('Ausnahme beim Löschen des Done-Eintrags', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteWatch(int id) async {
    _log.i('Lösche Watchlist-Eintrag mit ID: $id');
    try {
      await supabase
          .from('Watchlist')
          .delete()
          .eq('WatchlistID', id)
          .eq('UserID', User.id);
      if (mounted) {
        _log.i('Watchlist-Eintrag erfolgreich gelöscht.');
        setState(() => _watchlist.removeWhere((e) => e['WatchlistID'] == id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Von Watchlist entfernt'), backgroundColor: Colors.orangeAccent),
        );
      }
    } catch (e, st) {
      _log.e('Ausnahme beim Löschen des Watchlist-Eintrags', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markDone(int mid, int wid) async {
    _log.i('Markiere Berg $mid als erledigt, entferne von Watchlist $wid.');
    final now = DateTime.now().toIso8601String();
    try {
      final existingDone = await supabase
          .from('Done')
          .select('DoneID')
          .eq('UserID', User.id)
          .eq('MountainID', mid)
          .maybeSingle();

      if (existingDone != null) {
        _log.w('Berg $mid wurde bereits als erledigt markiert.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dieser Berg wurde bereits abgehakt.'), backgroundColor: Colors.orangeAccent));
          await _deleteWatch(wid);
          await _fetchWatchlist();
          if (mounted) setState(() {});
        }
        return;
      }

      await supabase.from('Done').insert(
          {'UserID': User.id, 'MountainID': mid, 'Date': now});
      _log.i('Berg $mid erfolgreich als erledigt markiert.');
      await _deleteWatch(wid);
      await _loadData();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Als gemacht markiert'), backgroundColor: Colors.green));
      }
    } catch (e, st) {
      _log.e('Fehler beim Markieren als erledigt', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _log.i('DonePage disposed.');
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.lightBlueAccent,
          labelColor: Colors.lightBlueAccent,
          unselectedLabelColor: Colors.white70,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "GEMACHT",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "WATCHLIST",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation(Colors.lightBlueAccent)))
          : TabBarView(
        controller: _tabController,
        children: [
          _doneView(),
          _watchView(),
        ],
      ),
    );
  }

  Widget _searchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              if (mounted) setState(() => _searchQuery = value);
            },
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Suche Bergname...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 22),
              filled: true,
              fillColor: const Color(0xFF505050),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  _filterState,
                  _availableStates,
                      (v) {
                    if (mounted && v != null) setState(() => _filterState = v);
                  },
                  hint: 'Bundesland',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                  _sortMode,
                  ['Neu → Alt', 'Alt → Neu', 'A → Z', 'Z → A'],
                      (v) {
                    if (mounted && v != null) setState(() => _sortMode = v);
                  },
                  hint: 'Sortieren',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doneView() {
    final items = _filteredDone;
    return Column(
      children: [
        _searchAndFilterBar(),
        Expanded(
          child: items.isEmpty
              ? Center(
              child: Text(
                  _searchQuery.isEmpty && _filterState == 'Alle'
                      ? 'Noch keine Berge abgehakt.'
                      : 'Keine Berge entsprechen deiner Suche/Filter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final e = items[i];
              return _entryCard(
                name: e['Mountain']?['Name'] ?? 'Unbekannter Berg',
                subtitle: 'Höhe: ${e['Mountain']?['Height'] ?? 'N/A'} m • ${e['Mountain']?['FederalState']?['Name'] ?? 'N/A'}',
                date: _formatDate(e['Date']),
                onDelete: () => _deleteDone(e['DoneID']),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _watchView() {
    final items = _filteredWatchlist;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) {
              if (mounted) setState(() => _searchQuery = value);
            },
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Suche Bergname...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 22),
              filled: true,
              fillColor: const Color(0xFF505050),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
              child: Text(
                  _searchQuery.isEmpty
                      ? 'Deine Watchlist ist leer.'
                      : 'Keine Berge auf der Watchlist entsprechen deiner Suche.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final e = items[i];
              return _entryCard(
                name: e['Mountain']?['Name'] ?? 'Unbekannter Berg',
                subtitle: 'Höhe: ${e['Mountain']?['Height'] ?? 'N/A'} m • ${e['Mountain']?['FederalState']?['Name'] ?? 'N/A'}',
                actionIcons: [
                  IconButton(
                      icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent[700], size: 26),
                      tooltip: 'Als gemacht markieren',
                      onPressed: () =>
                          _markDone(e['Mountain']['Mountainid'], e['WatchlistID'])),
                  IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent[700], size: 26),
                      tooltip: 'Von Watchlist entfernen',
                      onPressed: () => _deleteWatch(e['WatchlistID'])),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _entryCard({
    required String name,
    required String subtitle,
    String? date,
    VoidCallback? onDelete,
    List<Widget>? actionIcons,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        subtitle: Text(date != null ? '$date • $subtitle' : subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        trailing: actionIcons != null && actionIcons.isNotEmpty
            ? Row(mainAxisSize: MainAxisSize.min, children: actionIcons)
            : (onDelete != null
            ? IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.redAccent[700], size: 26),
            tooltip: 'Löschen',
            onPressed: onDelete)
            : null),
      ),
    );
  }

  Widget _buildDropdown(String currentValue, List<String> items,
      ValueChanged<String?> onChanged, {String? hint}) =>
      Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF505050),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(currentValue) ? currentValue : null,
            hint: hint != null ? Text(hint, style: const TextStyle(color: Colors.white54, fontSize: 15)) : null,
            isExpanded: true,
            dropdownColor: const Color(0xFF3c3c3c),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 24),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            items: items
                .map((s) => DropdownMenuItem(
              value: s,
              child: Text(s, overflow: TextOverflow.ellipsis),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}