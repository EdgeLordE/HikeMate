// pubspec.yaml dependencies:
// dependencies:
//   flutter:
//     sdk: flutter
//   supabase_flutter: ^1.0.0
//   flutter_map: ^6.0.1
//   latlong2: ^0.9.0
//   csv: ^5.0.0
//   path_provider: ^2.0.11

import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DonePage extends StatefulWidget {
  const DonePage({Key? key}) : super(key: key);

  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _doneList = [];
  List<Map<String, dynamic>> _watchlist = [];
  bool _isLoading = false;

  // Filter, search & sort
  String _searchQuery = '';
  String _filterState = 'Alle';
  String _sortMode = 'Neu → Alt';

  List<Map<String, dynamic>> get _filteredDone {
    var list = _doneList.where((e) {
      final name = (e['Mountain']['Name'] as String).toLowerCase();
      final state = (e['Mountain']['FederalState']['Name'] as String);
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
            (a['Mountain']['Name'] as String)
                .compareTo(b['Mountain']['Name'] as String));
        break;
      case 'Z → A':
        list.sort((a, b) =>
            (b['Mountain']['Name'] as String)
                .compareTo(a['Mountain']['Name'] as String));
        break;
      case 'Neu → Alt':
      default:
        list.sort((a, b) =>
            DateTime.parse(b['Date']).compareTo(DateTime.parse(a['Date'])));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchDone(), _fetchWatchlist()]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchDone() async {
    try {
      final res = await supabase
          .from('Done')
          .select(
          'DoneID, Date, Mountain(Mountainid,Name,Height,FederalState(Name))')
          .eq('UserID', User.id);
      _doneList = res is List
          ? List<Map<String, dynamic>>.from(res)
          : [];
    } catch (_) {
      _doneList = [];
    }
  }

  Future<void> _fetchWatchlist() async {
    try {
      final res = await supabase
          .from('Watchlist')
          .select('WatchlistID, Mountain(Mountainid,Name,Height,FederalState(Name))')
          .eq('UserID', User.id);
      _watchlist = res is List
          ? List<Map<String, dynamic>>.from(res)
          : [];
    } catch (_) {
      _watchlist = [];
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _deleteDone(int id) async {
    try {
      await supabase
          .from('Done')
          .delete()
          .eq('DoneID', id)
          .eq('UserID', User.id);
      setState(() => _doneList.removeWhere((e) => e['DoneID'] == id));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eintrag gelöscht')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future<void> _deleteWatch(int id) async {
    try {
      await supabase
          .from('Watchlist')
          .delete()
          .eq('WatchlistID', id)
          .eq('UserID', User.id);
      setState(() => _watchlist.removeWhere((e) => e['WatchlistID'] == id));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Von Watchlist entfernt')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future<void> _markDone(int mid, int wid) async {
    final now = DateTime.now().toIso8601String();
    try {
      await supabase.from('Done').insert(
          {'UserID': User.id, 'MountainID': mid, 'Date': now});
      await _deleteWatch(wid);
      await _fetchDone();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Als gemacht markiert')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future<void> _exportCsv() async {
    final rows = [
      ['Name', 'Höhe', 'Bundesland', 'Datum'],
      ..._doneList.map((e) => [
        e['Mountain']['Name'],
        e['Mountain']['Height'].toString(),
        e['Mountain']['FederalState']['Name'],
        _formatDate(e['Date']),
      ])
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/done.csv');
    await file.writeAsString(csv);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exportiert: done.csv')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        title: const Text('Meine Berge',
            style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.lightBlueAccent,
          tabs: const [Tab(text: 'Gemacht'), Tab(text: 'Watchlist')],
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                  Colors.lightBlueAccent)))
          : TabBarView(
        controller: _tabController,
        children: [
          _doneView(),
          _watchView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportCsv,
        child: const Icon(Icons.download),
        tooltip: 'Export CSV',
      ),
    );
  }

  Widget _doneView() {
    return Column(
      children: [
        _filterBar(),
        Expanded(flex: 3,
          child: _filteredDone.isEmpty
              ? const Center(
              child: Text('Noch keine Berge abgehakt.',
                  style: TextStyle(color: Colors.white54)))
              : ListView.builder(
            itemCount: _filteredDone.length,
            itemBuilder: (_, i) {
              final e = _filteredDone[i];
              return Dismissible(
                key: Key(e['DoneID'].toString()),
                background: _slideBg(Colors.red, Icons.delete),
                onDismissed: (_) => _deleteDone(e['DoneID']),
                child: _entryCard(
                  name: e['Mountain']['Name'],
                  subtitle: 'Höhe: ${e['Mountain']['Height']} m',
                  date: _formatDate(e['Date']),
                  onDelete: () => _deleteDone(e['DoneID']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _watchView() {
    return ListView.builder(
      itemCount: _watchlist.length,
      itemBuilder: (_, i) {
        final e = _watchlist[i];
        return _entryCard(
          name: e['Mountain']['Name'],
          subtitle: 'Höhe: ${e['Mountain']['Height']} m',
          actionIcons: [
            IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () =>
                    _markDone(e['Mountain']['Mountainid'], e['WatchlistID'])),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteWatch(e['WatchlistID'])),
          ],
        );
      },
    );
  }

  Widget _filterBar() => Card(
    color: const Color(0xFF1E1E1E),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded( // Suchfeld nimmt übrigen Platz ein
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Suche...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded( // Dropdowns nehmen gleichmäßigen Platz ein
            child: _buildDropdown(
              _filterState,
              ['Alle', 'Tirol', 'Salzburg', 'Kärnten', 'Vorarlberg', 'Wien'],
                  (v) => setState(() => _filterState = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropdown(
              _sortMode,
              ['Neu → Alt', 'Alt → Neu', 'A → Z', 'Z → A'],
                  (v) => setState(() => _sortMode = v!),
            ),
          ),
        ],
      ),
    ),
  );


  Widget _entryCard({
    required String name,
    required String subtitle,
    String? date,
    VoidCallback? onDelete,
    List<Widget>? actionIcons,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
            date != null ? '$date • $subtitle' : subtitle,
            style: const TextStyle(color: Colors.white70)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (actionIcons != null) ...actionIcons,
          if (onDelete != null)
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete),
        ]),
      ),
    );
  }

  Widget _slideBg(Color c, IconData i) => Container(
    color: c,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 16),
    child: Icon(i, color: Colors.white),
  );

  // Helper for styled dropdowns
  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF2C2C2C),
        underline: const SizedBox(),
        isExpanded: true, // <- hinzugefügt
        style: const TextStyle(color: Colors.white),
        items: items
            .map((s) => DropdownMenuItem(
          value: s,
          child: Text(s, style: const TextStyle(color: Colors.white)),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
