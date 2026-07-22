import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notifications.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primary = Color(0xFF22C55E);
  static const Color background = Color(0xFF020617);
  static const Color cardColor = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : "FitFlow User";

    final String userEmail = user?.email ?? "No email available";

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: primary, size: 27),
            SizedBox(width: 10),
            Text(
              "FitFlow",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Notifications",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Badge(
              label: Text("2"),
              child: Icon(Icons.notifications_outlined, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, $userName 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                userEmail,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final data = await ApiService.getCurrentUser();

                      debugPrint('FASTAPI USER: $data');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backend connected: ${data['email']}'),
                          backgroundColor: const Color(0xFF22C55E),
                        ),
                      );
                    } catch (e) {
                      debugPrint('API ERROR: $e');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backend error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.cloud_done_outlined),
                  label: const Text(
                    "TEST BACKEND CONNECTION",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildFitnessSummary(),

              const SizedBox(height: 30),

              const Text(
                "Quick Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Your fitness activity at a glance.",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 18),

              const Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      icon: Icons.fitness_center,
                      title: "Workouts",
                      value: "0",
                      subtitle: "This week",
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: _OverviewCard(
                      icon: Icons.local_fire_department,
                      title: "Current Streak",
                      value: "0 days",
                      subtitle: "Keep going",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                "This Week",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _buildWeeklyProgress(),

              const SizedBox(height: 28),

              const Row(
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.history, color: Colors.white38, size: 21),
                ],
              ),

              const SizedBox(height: 15),

              _buildRecentActivity(),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFitnessSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF052E16), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: primary, size: 25),
              SizedBox(width: 10),
              Text(
                "Your Fitness Today",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            "A quick summary of your latest health metrics.",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),

          SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _HealthMetric(
                  icon: Icons.calculate_outlined,
                  title: "BMI",
                  value: "--",
                ),
              ),

              SizedBox(width: 10),

              Expanded(
                child: _HealthMetric(
                  icon: Icons.monitor_weight_outlined,
                  title: "Weight",
                  value: "-- kg",
                ),
              ),

              SizedBox(width: 10),

              Expanded(
                child: _HealthMetric(
                  icon: Icons.local_fire_department_outlined,
                  title: "Calories",
                  value: "-- kcal",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Weekly Workout Goal",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                "0 / 5",
                style: TextStyle(
                  color: primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 9,
              backgroundColor: Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),

          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekDay(day: "M"),
              _WeekDay(day: "T"),
              _WeekDay(day: "W"),
              _WeekDay(day: "T"),
              _WeekDay(day: "F"),
              _WeekDay(day: "S"),
              _WeekDay(day: "S"),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            "Complete workouts to track your weekly consistency.",
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_toggle_off, color: Colors.white30, size: 45),

          SizedBox(height: 13),

          Text(
            "No recent activity",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Your latest workouts, health updates and fitness activity will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HealthMetric({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF22C55E), size: 21),

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: const Color(0xFF22C55E), size: 21),
          ),

          const SizedBox(height: 15),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: const TextStyle(color: Colors.white30, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String day;

  const _WeekDay({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.circle_outlined,
            color: Colors.white24,
            size: 15,
          ),
        ),

        const SizedBox(height: 6),

        Text(day, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
