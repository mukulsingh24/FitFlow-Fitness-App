import 'package:flutter/material.dart';

import 'bmi.dart';
import 'calorie.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BmiCalculatorScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              HealthFeatureCard(
                icon: Icons.local_fire_department_outlined,
                title: "Calorie Calculator",
                description:
                    "Estimate your daily calorie needs based on your body and activity.",
                buttonText: "Calculate Calories",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalorieCalculatorScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              HealthFeatureCard(
                icon: Icons.monitor_weight_outlined,
                title: "Weight Tracker",
                description:
                    "Track your body weight and monitor changes over time.",
                buttonText: "Coming Soon",
                disabled: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Weight Tracker will be available soon."),
                      backgroundColor: Color.fromARGB(255, 123, 255, 0),
                    ),
                  );
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

              _buildEmptyHistory(),

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
          const Row(
            children: [
              Expanded(
                child: _SummaryItem(title: "BMI", value: "--"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(title: "Calories", value: "-- kcal"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(title: "Weight", value: "-- kg"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scaffoldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_outlined,
              color: textMuted,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "No health history yet",
            style: TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Your BMI, calorie and weight history will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
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
