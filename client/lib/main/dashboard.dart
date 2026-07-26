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

  List<Map<String, dynamic>> recentActivity = [];
  double? latestBmi;
  double? latestCalories;
  double? latestWeight;
  bool isLoadingHealth = true;
  int workoutsThisWeek = 0;
  int currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadLatestHealthData();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    _loadLatestHealthData();
  }

  Future<void> _loadLatestHealthData() async {
    try {
      final results = await Future.wait([
        ApiService.getBMIHistory(),
        ApiService.getCalorieHistory(),
        ApiService.getWeightHistory(),
        ApiService.getWorkoutHistory(),
      ]);

      final bmiHistory = results[0];
      final calorieHistory = results[1];
      final weightHistory = results[2];
      final workoutHistory = results[3];
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final weekStart = todayDate.subtract(
        Duration(days: todayDate.weekday - 1),
      );
      final weeklyWorkouts = workoutHistory.where((workout) {
        final date = DateTime.parse(workout["workout_date"]);
        final workoutDate = DateTime(date.year, date.month, date.day);

        return !workoutDate.isBefore(weekStart);
      }).length;
      final workoutDates = workoutHistory.map<DateTime>((workout) {
        final date = DateTime.parse(workout["workout_date"]);
        return DateTime(date.year, date.month, date.day);
      }).toSet();
      int streak = 0;
      DateTime current = todayDate;
      if (!workoutDates.contains(current)) {
        current = current.subtract(const Duration(days: 1));

        if (!workoutDates.contains(current)) {
          streak = 0;
        }
      }
      while (workoutDates.contains(current)) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      }
      final List<Map<String, dynamic>> activities = [];
      for (final record in bmiHistory) {
        activities.add({
          "type": "bmi",
          "created_at": record["created_at"],
          "bmi": record["bmi"],
          "weight": record["weight"],
        });
      }
      for (final record in calorieHistory) {
        activities.add({
          "type": "calorie",
          "created_at": record["created_at"],
          "calories": record["target_calories"],
          "goal": record["goal"],
        });
      }
      for (final record in weightHistory) {
        activities.add({
          "type": "weight",
          "created_at": record["created_at"],
          "weight": record["weight"],
        });
      }
      for (final workout in workoutHistory) {
        activities.add({
          "type": "workout",
          "created_at": workout["created_at"],
          "workout_day": workout["workout_day"],
          "exercise_count": (workout["exercises"] as List).length,
        });
      }
      activities.sort((a, b) {
        final aDate = DateTime.parse(a["created_at"]);
        final bDate = DateTime.parse(b["created_at"]);

        return bDate.compareTo(aDate);
      });
      if (!mounted) return;

      setState(() {
        if (bmiHistory.isNotEmpty) {
          latestBmi = (bmiHistory.first["bmi"] as num?)?.toDouble();
        }

        if (calorieHistory.isNotEmpty) {
          latestCalories = (calorieHistory.first["target_calories"] as num?)
              ?.toDouble();
        }

        if (weightHistory.isNotEmpty) {
          latestWeight = (weightHistory.first["weight"] as num?)?.toDouble();
        }

        recentActivity = activities.take(10).toList();
        workoutsThisWeek = weeklyWorkouts;
        currentStreak = streak;
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
                "Welcome back, $userName",
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

              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      icon: Icons.fitness_center,
                      title: "Workouts",
                      value: "$workoutsThisWeek",
                      subtitle: "This week",
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: _OverviewCard(
                      icon: Icons.local_fire_department,
                      title: "Current Streak",
                      value: "$currentStreak",
                      subtitle: currentStreak == 1 ? "day" : "days",
                    ),
                  ),
                ],
              ),
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

  Widget _buildRecentActivity() {
    if (isLoadingHealth) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recentActivity.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: const Column(
          children: [
            Icon(Icons.history_rounded, color: textMuted, size: 30),
            SizedBox(height: 12),
            Text(
              "No recent activity",
              style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Your recent workouts and health updates will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentActivity.map((activity) {
        final type = activity["type"];

        final date = DateTime.tryParse(
          activity["created_at"]?.toString() ?? "",
        );

        String dateText = "";

        if (date != null) {
          dateText = "${date.day}/${date.month}/${date.year}";
        }

        IconData icon;
        String title;
        String subtitle;

        switch (type) {
          case "bmi":
            icon = Icons.favorite_outline_rounded;

            title = "BMI Recorded";

            subtitle =
                "${(activity["bmi"] as num).toStringAsFixed(1)} BMI"
                " • "
                "${(activity["weight"] as num).toStringAsFixed(1)} kg";

            break;

          case "calorie":
            icon = Icons.local_fire_department_outlined;

            title = "Calorie Target";

            subtitle =
                "${(activity["calories"] as num).round()} kcal"
                " • ${activity["goal"]}";

            break;

          case "weight":
            icon = Icons.monitor_weight_outlined;

            title = "Weight Logged";

            subtitle = "${(activity["weight"] as num).toStringAsFixed(1)} kg";

            break;

          case "workout":
            icon = Icons.fitness_center;

            title = activity["workout_day"];

            subtitle = "${activity["exercise_count"]} exercises completed";

            break;

          default:
            icon = Icons.history;

            title = "Activity";

            subtitle = "";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: softMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryDark),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              Text(
                dateText,
                style: const TextStyle(color: textMuted, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
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
