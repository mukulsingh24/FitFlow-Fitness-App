import 'package:flutter/material.dart';

import 'bmi.dart';
import 'calorie.dart';
import '../services/api_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  double? latestBmi;
  double? latestWeight;
  double? latestCalories;
  bool isLoadingHealth = true;
  List<Map<String, dynamic>> recentHealthActivity = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    try {
      final results = await Future.wait([
        ApiService.getBMIHistory(),
        ApiService.getCalorieHistory(),
      ]);

      final bmiHistory = results[0];
      final calorieHistory = results[1];

      final List<Map<String, dynamic>> activities = [];

      for (final record in bmiHistory) {
        activities.add({
          'type': 'bmi',
          'bmi': record['bmi'],
          'weight': record['weight'],
          'created_at': record['created_at'],
        });
      }

      for (final record in calorieHistory) {
        activities.add({
          'type': 'calorie',
          'calories': record['target_calories'],
          'goal': record['goal'],
          'created_at': record['created_at'],
        });
      }

      activities.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '');

        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '');

        if (aDate == null || bDate == null) {
          return 0;
        }

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        if (bmiHistory.isNotEmpty) {
          final latestBMI = bmiHistory.first;

          latestBmi = (latestBMI['bmi'] as num?)?.toDouble();

          latestWeight = (latestBMI['weight'] as num?)?.toDouble();
        }

        if (calorieHistory.isNotEmpty) {
          final latestCalorie = calorieHistory.first;

          latestCalories = (latestCalorie['target_calories'] as num?)
              ?.toDouble();
        }

        recentHealthActivity = activities.take(5).toList();

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
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Health",
              style: TextStyle(
                color: textDark,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "Understand and track your body",
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthSummary(),
              const SizedBox(height: 28),

              const Text(
                "Health Tools",
                style: TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Calculate and monitor your fitness metrics.",
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),

              HealthFeatureCard(
                icon: Icons.calculate_outlined,
                title: "BMI Calculator",
                description:
                    "Calculate your Body Mass Index using your height and weight.",
                buttonText: "Calculate BMI",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BmiCalculatorScreen(),
                    ),
                  );

                  if (!mounted) return;

                  await _loadHealthData();
                },
              ),

              const SizedBox(height: 12),

              HealthFeatureCard(
                icon: Icons.local_fire_department_outlined,
                title: "Calorie Calculator",
                description:
                    "Estimate your daily calorie needs based on your body and activity.",
                buttonText: "Calculate Calories",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalorieCalculatorScreen(),
                    ),
                  );

                  if (!mounted) return;

                  await _loadHealthData();
                },
              ),
              const SizedBox(height: 28),
              const Row(
                children: [
                  Text(
                    "Recent Health Activity",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.history_rounded, color: textMuted, size: 20),
                ],
              ),

              const SizedBox(height: 14),
              _buildRecentHealthActivity(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummary() {
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Health Overview",
            style: TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Use FitFlow's health tools to understand your body and support your fitness goals.",
            style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
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
                child: _SummaryItem(
                  title: "Calories",
                  value: isLoadingHealth
                      ? "..."
                      : latestCalories != null
                      ? "${latestCalories!.round()} kcal"
                      : "-- kcal",
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _SummaryItem(
                  title: "Weight",
                  value: isLoadingHealth
                      ? "..."
                      : latestWeight != null
                      ? "${latestWeight!.toStringAsFixed(1)} kg"
                      : "-- kg",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHealthActivity() {
    if (isLoadingHealth) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recentHealthActivity.isEmpty) {
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
            Icon(Icons.insights_outlined, color: textMuted, size: 30),
            SizedBox(height: 12),
            Text(
              "No health history yet",
              style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Your BMI and calorie history will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentHealthActivity.map((activity) {
        final bool isBMI = activity['type'] == 'bmi';

        final date = DateTime.tryParse(
          activity['created_at']?.toString() ?? '',
        );

        String dateText = '';

        if (date != null) {
          dateText = '${date.day}/${date.month}/${date.year}';
        }

        String title;
        String subtitle;

        if (isBMI) {
          final bmi = (activity['bmi'] as num?)?.toDouble();

          final weight = (activity['weight'] as num?)?.toDouble();

          title = 'BMI Recorded';

          subtitle =
              '${bmi?.toStringAsFixed(1) ?? '--'} BMI'
              ' • '
              '${weight?.toStringAsFixed(1) ?? '--'} kg';
        } else {
          final calories = (activity['calories'] as num?)?.toDouble();

          final goal = activity['goal']?.toString() ?? '';

          title = 'Calorie Target';

          subtitle =
              '${calories?.round() ?? '--'} kcal'
              ' • $goal';
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
                child: Icon(
                  isBMI
                      ? Icons.favorite_outline_rounded
                      : Icons.local_fire_department_outlined,
                  color: primaryDark,
                ),
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

class HealthFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;
  final bool disabled;

  const HealthFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
    this.disabled = false,
  });

  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: softMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primaryDark, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: disabled ? textMuted : primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, color: textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryItem({required this.title, required this.value});

  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
