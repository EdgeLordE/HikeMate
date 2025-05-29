import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    this.username,
    this.totalDistance = 0,
    this.totalAscent = 0,
    this.totalDurationHours = 0,
    this.totalActivities = 0,
    this.totalCalories = 0,
    this.averageSpeed = 0,
    this.maxElevation = 0,
    this.onLogout,
    this.onChangePassword,
    this.onChangeUsername,
  }) : super(key: key);

  final String? username;
  final num totalDistance;
  final num totalAscent;
  final num totalDurationHours;
  final int totalActivities;
  final int totalCalories;
  final double averageSpeed;
  final int maxElevation;
  final VoidCallback? onLogout;
  final VoidCallback? onChangePassword;
  final VoidCallback? onChangeUsername;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.lightBlueAccent, size: 30),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = (widget.username?.isNotEmpty ?? false)
        ? widget.username!.substring(0, 1).toUpperCase()
        : '?';

    final stats = [
      _buildStat(Icons.route, 'Distanz', '${widget.totalDistance.toStringAsFixed(1)} km'),
      _buildStat(Icons.terrain, 'Anstieg', '${widget.totalAscent.toStringAsFixed(0)} m'),
      _buildStat(Icons.timer, 'Dauer', '${widget.totalDurationHours.toStringAsFixed(1)} h'),
      _buildStat(Icons.fitness_center, 'Aktivitäten', '${widget.totalActivities}x'),
      _buildStat(Icons.local_fire_department, 'Kalorien', '${widget.totalCalories} kcal'),
      _buildStat(Icons.speed, 'Ø Geschwindigkeit', '${widget.averageSpeed.toStringAsFixed(1)} km/h'),
      _buildStat(Icons.vertical_align_top, 'Max Höhe', '${widget.maxElevation} m'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.lightBlueAccent,
                  child: Text(initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: stats,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.lightBlueAccent),
                      title: const Text('Benutzernamen ändern', style: TextStyle(color: Colors.white)),
                      onTap: widget.onChangeUsername,
                    ),
                    const Divider(height: 1, color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.lightBlueAccent),
                      title: const Text('Passwort ändern', style: TextStyle(color: Colors.white)),
                      onTap: widget.onChangePassword,
                    ),


                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Abmelden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
