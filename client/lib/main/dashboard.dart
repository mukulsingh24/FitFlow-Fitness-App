import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: Color(0xFF22C55E)),
            SizedBox(width: 10),
            Text(
              "FitFlow",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout, color: Color(0xFF0F172A)),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to FitFlow 💪",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                user?.email ?? "FitFlow User",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Color(0xFF22C55E),
                      size: 40,
                    ),

                    SizedBox(height: 20),

                    Text(
                      "Your Fitness Journey",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Track your workouts, calories, BMI, body weight and weekly progress.",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.local_fire_department_outlined,
                      title: "Calories",
                      value: "0 kcal",
                    ),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: DashboardCard(
                      icon: Icons.monitor_weight_outlined,
                      title: "Weight",
                      value: "-- kg",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.calculate_outlined,
                      title: "BMI",
                      value: "--",
                    ),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: DashboardCard(
                      icon: Icons.fitness_center,
                      title: "Workouts",
                      value: "0",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFF22C55E)),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
