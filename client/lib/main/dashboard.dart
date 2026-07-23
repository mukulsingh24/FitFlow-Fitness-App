import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notifications.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  double? latestBmi;
  double? latestWeight;
  bool isLoadingHealth = true;
  double? latestCalories;

  @override
  void initState() {
    super.initState();
    _loadLatestHealthData();
  }

  Future<void> _loadLatestHealthData() async {
    try {
      final bmiData = await ApiService.getLatestBMI();
      final calorieData = await ApiService.getLatestCalories();

      if (!mounted) return;

      setState(() {
        if (bmiData != null) {
          latestBmi = (bmiData['bmi'] as num?)?.toDouble();
          latestWeight = (bmiData['weight'] as num?)?.toDouble();
        }

        if (calorieData != null) {
          latestCalories = (calorieData['target_calories'] as num?)?.toDouble();
        }

        isLoadingHealth = false;
      });
    } catch (e) {
      debugPrint('HEALTH DATA ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingHealth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : "FitFlow User";

    final String userEmail = user?.email ?? "No email available";

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "FitFlow",
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
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
              backgroundColor: primary,
              label: Text("2"),
              child: Icon(Icons.notifications_outlined, color: textDark),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, $userName 👋",
                style: const TextStyle(
                  color: textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                userEmail,
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final data = await ApiService.getCurrentUser();

                      debugPrint('FASTAPI USER: $data');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backend connected: ${data['email']}'),
                          backgroundColor: primaryDark,
                        ),
                      );
                    } catch (e) {
                      debugPrint('API ERROR: $e');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backend error: $e'),
                          backgroundColor: const Color(0xFFEF6C6C),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryDark,
                    side: const BorderSide(color: border),
                    backgroundColor: surface,
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

              const SizedBox(height: 24),

              _buildFitnessSummary(),

              const SizedBox(height: 28),

              const Text(
                "Quick Overview",
                style: TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Your fitness activity at a glance.",
                style: TextStyle(color: textMuted, fontSize: 13),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 26),

              const Text(
                "This Week",
                style: TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              _buildWeeklyProgress(),

              const SizedBox(height: 26),

              const Row(
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.history_rounded, color: textMuted, size: 20),
                ],
              ),

              const SizedBox(height: 14),

              _buildRecentActivity(),

              const SizedBox(height: 20),
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
        color: softMint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: primaryDark, size: 22),
              SizedBox(width: 10),
              Text(
                "Your Fitness Today",
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "A quick summary of your latest health metrics.",
            style: TextStyle(color: textMuted, fontSize: 12),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _HealthMetric(
                  icon: Icons.calculate_outlined,
                  title: "BMI",
                  value: isLoadingHealth
                      ? "..."
                      : latestBmi != null
                      ? latestBmi!.toStringAsFixed(1)
                      : "--",
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _HealthMetric(
                  icon: Icons.monitor_weight_outlined,
                  title: "Weight",
                  value: isLoadingHealth
                      ? "..."
                      : latestWeight != null
                      ? "${latestWeight!.toStringAsFixed(1)} kg"
                      : "-- kg",
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _HealthMetric(
                  icon: Icons.local_fire_department_outlined,
                  title: "Calories",
                  value: isLoadingHealth
                      ? "..."
                      : latestCalories != null
                      ? "${latestCalories!.round()} kcal"
                      : "-- kcal",
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
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Weekly Workout Goal",
                style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                "0 / 5",
                style: TextStyle(
                  color: primaryDark,
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
              backgroundColor: scaffoldBg,
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
            style: TextStyle(color: textMuted, fontSize: 11),
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
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: scaffoldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: textMuted,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "No recent activity",
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Your latest workouts, health updates and fitness activity will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 12, height: 1.5),
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

  static const Color primaryDark = Color(0xFF128C3F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryDark, size: 20),

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(color: textMuted, fontSize: 10)),
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

  //static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: softMint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: primaryDark, size: 19),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: const TextStyle(color: textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String day;

  const _WeekDay({required this.day});

  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color textMuted = Color(0xFF6B7570);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: scaffoldBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.circle_outlined, color: textMuted, size: 15),
        ),

        const SizedBox(height: 6),

        Text(day, style: const TextStyle(color: textMuted, fontSize: 10)),
      ],
    );
  }
}
