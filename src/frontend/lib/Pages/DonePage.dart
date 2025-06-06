import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';

class DonePage extends StatefulWidget {
  const DonePage({Key? key}) : super(key: key);

  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  List<Map<String, dynamic>> _doneList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoneMountains();
  }

  Future<void> _fetchDoneMountains() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('Done')
          .select(r'''
            DoneID,
            Date,
            Mountain (
              Mountainid,
              Name,
              Height,
              FederalState ( Name )
            )
          ''')
          .eq('UserID', User.id);

      if (!mounted) return;
      if (response is List) {
        setState(() {
          _doneList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          _doneList = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden: $e')),
      );
      setState(() {
        _doneList = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDoneEntry(int doneID) async {
    try {
      final deleteResponse = await supabase
          .from('Done')
          .delete()
          .eq('DoneID', doneID);

      if (deleteResponse == null ||
          (deleteResponse is List && deleteResponse.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eintrag nicht gefunden')),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _doneList.removeWhere((entry) => entry['DoneID'] == doneID);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eintrag erfolgreich gelöscht')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen: $e')),
      );
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        title: const Text(
          'Gemachte Berge',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doneList.isEmpty
          ? const Center(
        child: Text(
          'Noch keine Berge hinzugefügt.',
          style: TextStyle(color: Colors.white54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _doneList.length,
        itemBuilder: (ctx, index) {
          final doneEntry = _doneList[index];
          final doneId = doneEntry['DoneID'] as int;
          final dateRaw = doneEntry['Date'] as String;
          final mountain =
          doneEntry['Mountain'] as Map<String, dynamic>;
          final name = mountain['Name'] as String? ?? '–';
          final height = mountain['Height']?.toString() ?? '–';
          final federalState =
              (mountain['FederalState'] as Map<String, dynamic>?)?['Name']
              as String? ??
                  '–';

          return Card(
            color: const Color(0xFF1E1E1E),
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datum: ${_formatDate(dateRaw)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Höhe: $height m, Bundesland: $federalState',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF282828),
                      title: const Text(
                        'Eintrag löschen?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Möchtest du „$name“ wirklich löschen?',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'Abbrechen',
                            style: TextStyle(color: Colors.lightBlueAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _deleteDoneEntry(doneId);
                          },
                          child: const Text(
                            'Löschen',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
