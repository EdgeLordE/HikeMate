import 'package:flutter/material.dart';
import '../Class/User.dart';
import 'settings_page.dart';
import '../Class/Activity.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
        setState(() => _isLoading = false);
        return;
      }

      // Aktivitäten über die REST-API laden
      final rows = await Activity.fetchActivitiesByUserId(currentUserId);

      double sumDist = 0.0;
      int sumAscent = 0;
      double sumDuration = 0.0;
      int sumCalories = 0;
      int maxAlt = 0;

      for (final row in rows) {
        sumDist += (row['Distance'] as num?)?.toDouble() ?? 0.0;
        sumAscent += (row['Increase'] as num?)?.toInt() ?? 0;
        sumDuration += (row['Duration'] as num?)?.toDouble() ?? 0.0;
        sumCalories += (row['Calories'] as num?)?.toInt() ?? 0;
        final alt = (row['MaxAltitude'] as num?)?.toInt() ?? 0;
        if (alt > maxAlt) maxAlt = alt;
      }

      final activityCount = rows.length;
      final avgSpeed = sumDuration > 0 ? sumDist / sumDuration : 0.0;

      if (mounted) {
        setState(() {
          _totalDistance = sumDist / 1000; // km
          _totalAscent = sumAscent; // m
          _totalDuration = sumDuration / 3600; // h
          _totalActivities = activityCount;
          _totalCalories = sumCalories;
          _averageSpeed = avgSpeed; // km/h
          _maxElevation = maxAlt; // m
          _activities = rows;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Statistiken: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.lightBlueAccent, size: 30),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final dist = ((activity['Distance'] as num?)?.toDouble() ?? 0.0) / 1000;
    final ascent = (activity['Increase'] as num?)?.toInt() ?? 0;
    final dur = ((activity['Duration'] as num?)?.toDouble() ?? 0.0) / 3600;
    final cal = (activity['Calories'] as num?)?.toInt() ?? 0;
    final alt = (activity['MaxAltitude'] as num?)?.toInt() ?? 0;

    DateTime date;
    try {
      date = DateTime.parse(activity['Date'] as String);
    } catch (_) {
      date = DateTime.now(); // Fallback, falls das Datum ungültig ist
    }
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.lightBlueAccent),
            const SizedBox(height: 4),
            Text(formattedDate,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        title: Text(
            'Distanz: ${dist.toStringAsFixed(1)} km, Dauer: ${dur.toStringAsFixed(1)} h',
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        subtitle: Text(
            'Anstieg: $ascent m • Kalorien: $cal kcal • Max H: $alt m',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = User.username;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141212),
        body: Center(
            child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent))),
      );
    }

    final stats = [
      _buildStat(
          Icons.route, 'Distanz', '${_totalDistance.toStringAsFixed(1)} km'),
      _buildStat(Icons.terrain, 'Anstieg', '$_totalAscent m'),
      _buildStat(
          Icons.timer, 'Dauer', '${_totalDuration.toStringAsFixed(1)} h'),
      _buildStat(Icons.fitness_center, 'Aktivitäten', '$_totalActivities x'),
      _buildStat(
          Icons.local_fire_department, 'Kalorien', '$_totalCalories kcal'),
      _buildStat(Icons.speed, 'Ø Geschwindigkeit',
          '${_averageSpeed.toStringAsFixed(1)} km/h'),
      _buildStat(Icons.vertical_align_top, 'Max Höhe', '$_maxElevation m'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF141212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141212),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20, // Vergrößerter Radius
              backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
              child: Text(
                initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Vergrößerte Schriftgröße
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22, // Vergrößerte Schriftgröße
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: Colors.lightBlueAccent, size: 30), // Icon Größe
            color: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) async {
              if (value == 'settings') {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()));
              } else if (value == 'logout') {
                await User.logout(context);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        color: Colors.lightBlueAccent.withOpacity(0.8)),
                    const SizedBox(width: 10),
                    const Text('Einstellungen',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined,
                        color: Colors.lightBlueAccent.withOpacity(0.8)),
                    const SizedBox(width: 10),
                    const Text('Abmelden',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gesamtstatistik',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 24),
                        Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 16,
                            runSpacing: 20,
                            children: stats),
                      ]),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Aktivitätenverlauf',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            if (_activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: Text('Noch keine Aktivitäten aufgezeichnet.',
                      style: TextStyle(color: Colors.white54, fontSize: 16)),
                ),
              )
            else
              ..._activities.map(_buildActivityItem),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}