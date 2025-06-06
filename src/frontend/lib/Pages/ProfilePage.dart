import 'package:flutter/material.dart';
import '../Class/supabase_client.dart';
import '../Class/User.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    this.onLogout,
    this.onChangePassword,
    this.onChangeUsername,
  }) : super(key: key);

  final VoidCallback? onLogout;
  final VoidCallback? onChangePassword;
  final VoidCallback? onChangeUsername;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  double _totalDistance = 0.0;
  int _totalAscent = 0;
  double _totalDuration = 0.0;
  int _totalActivities = 0;
  int _totalCalories = 0;
  double _averageSpeed = 0.0;
  int _maxElevation = 0;

  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _fetchStatsAndActivities();
  }

  Future<void> _fetchStatsAndActivities() async {
    try {
      final int currentUserId = User.id;
      if (currentUserId <= 0) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final List<dynamic> response = await supabase
          .from('Activity')
          .select('Distance, Increase, Duration, Calories, MaxAltitude, Date')
          .eq('UserID', currentUserId)
          .order('Date', ascending: false);

      final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(response);

      double sumDist = 0.0;
      int sumAscent = 0;
      double sumDuration = 0.0;
      int sumCalories = 0;
      int maxAlt = 0;

      for (final row in rows) {
        final dist = (row['Distance'] as num?)?.toDouble() ?? 0.0;
        final ascent = (row['Increase'] as num?)?.toInt() ?? 0;
        final dur = (row['Duration'] as num?)?.toDouble() ?? 0.0;
        final cal = (row['Calories'] as num?)?.toInt() ?? 0;
        final alt = (row['MaxAltitude'] as num?)?.toInt() ?? 0;

        sumDist += dist;
        sumAscent += ascent;
        sumDuration += dur;
        sumCalories += cal;
        if (alt > maxAlt) {
          maxAlt = alt;
        }
      }

      final int activityCount = rows.length;
      final double avgSpeed = (sumDuration > 0) ? (sumDist / sumDuration) : 0.0;

      setState(() {
        _totalDistance = sumDist;
        _totalAscent = sumAscent;
        _totalDuration = sumDuration;
        _totalActivities = activityCount;
        _totalCalories = sumCalories;
        _averageSpeed = avgSpeed;
        _maxElevation = maxAlt;
        _activities = rows;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Fehler beim Laden der Statistiken: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.lightBlueAccent, size: 30),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final dist = (activity['Distance'] as num?)?.toDouble() ?? 0.0;
    final ascent = (activity['Increase'] as num?)?.toInt() ?? 0;
    final dur = (activity['Duration'] as num?)?.toDouble() ?? 0.0;
    final cal = (activity['Calories'] as num?)?.toInt() ?? 0;
    final alt = (activity['MaxAltitude'] as num?)?.toInt() ?? 0;
    final dateString = activity['Date'] as String? ?? '';
    DateTime date;
    try {
      date = DateTime.parse(dateString);
    } catch (_) {
      date = DateTime.now();
    }

    final formattedDate = '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';

    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.lightBlueAccent),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        title: Text(
          'Distanz: ${dist.toStringAsFixed(1)} km, Dauer: ${dur.toStringAsFixed(1)} h',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Anstieg: ${ascent} m • Kalorien: ${cal} kcal • Max H: ${alt} m',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = User.username;
    final initial = (userName.isNotEmpty) ? userName.substring(0, 1).toUpperCase() : '?';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F1F1F),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
          ),
        ),
      );
    }

    final statsWidgets = <Widget>[
      _buildStat(Icons.route, 'Distanz', '${_totalDistance.toStringAsFixed(1)} km'),
      _buildStat(Icons.terrain, 'Anstieg', '${_totalAscent.toStringAsFixed(0)} m'),
      _buildStat(Icons.timer, 'Dauer', '${_totalDuration.toStringAsFixed(1)} h'),
      _buildStat(Icons.fitness_center, 'Aktivitäten', '${_totalActivities}x'),
      _buildStat(Icons.local_fire_department, 'Kalorien', '${_totalCalories} kcal'),
      _buildStat(Icons.speed, 'Ø Geschwindigkeit', '${_averageSpeed.toStringAsFixed(1)} km/h'),
      _buildStat(Icons.vertical_align_top, 'Max Höhe', '${_maxElevation} m'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.lightBlueAccent,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gesamtstatistik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: statsWidgets,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Aktivitätenverlauf',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (_activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Noch keine Aktivitäten aufgezeichnet.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ..._activities.map((act) => _buildActivityItem(act)),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.lightBlueAccent),
                      title: const Text(
                        'Benutzernamen ändern',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: widget.onChangeUsername,
                    ),
                    const Divider(height: 1, color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.lightBlueAccent),
                      title: const Text(
                        'Passwort ändern',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: widget.onChangePassword,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Abmelden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onLogout,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
