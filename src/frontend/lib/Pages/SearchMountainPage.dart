import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';

class SearchMountainPage extends StatefulWidget {
  const SearchMountainPage({super.key});

  @override
  State<SearchMountainPage> createState() => _SearchMountainPageState();
}

class _SearchMountainPageState extends State<SearchMountainPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? mountainData;

  Future<void> fetchMountainData(String name) async {
    try {
      final response = await supabase
          .from('Mountain')
          .select('Mountainid ,Name, Height, FederalStateid, FederalState ( Name )')
          .ilike('Name', name)
          .maybeSingle();
      if (response['Name'] != null) {
        setState(() {
          mountainData = response;
        });
      } else {
        setState(() {
          mountainData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg nicht gefunden')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berg nicht gefunden")),
      );
    }
  }

  Future<void> addMountain() async {

    int state = 0;
    if (mountainData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Bergdaten verfügbar')),
      );
      return;
    }

    try{
      final response = await supabase
          .from('Done')
          .select('MountainID')
          .eq('UserID', User.id)
          .eq('MountainID', mountainData!['Mountainid'])
          .limit(1)
          .maybeSingle();


      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg bereits hinzugefügt')),
        );
      } else{
        state = 1;
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Überprüfen des Berges: $e')),
      );
      return;
    }

    if (state == 1) {
      try {
        await supabase.from('Done').insert({
          'UserID': User.id,
          'MountainID': mountainData!['Mountainid'],
          'Date': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berg erfolgreich hinzugefügt')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen des Berges: $e')),
        );
      }
    }
  }

  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF505050),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          mountainData == null
              ? const Center(
            child: Text(
              'Bitte suche nach einem Berg',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          )
              : SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 200,
                    color: Colors.grey,
                    child: const Center(
                      child: Text(
                        'Bild Platzhalter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mountainData!['Name'] ?? 'Unbekannt',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBox('Höhe', '${mountainData!['Height']} m'),
                      const SizedBox(width: 10),
                      _buildInfoBox('Bundesland',
                          mountainData!['FederalState']?['Name'] ?? 'Unbekannt'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: addMountain,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Berg hinzufügen',
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}