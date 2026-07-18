import 'package:flutter/material.dart';
import './auth/register.dart';
import './auth/login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primary = Color(0xFF22C55E);
  static const Color darkBg = Color(0xFF020617);
  static const Color cardBg = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavbar(context),
              _buildHero(context),
              _buildFeatures(),
              _buildHowItWorks(),
              _buildCTA(context),
              _buildContact(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "FitFlow",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text(
              "Get Started",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF052E16), Color(0xFF0F172A), Color(0xFF020617)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text(
            "Build Strength.\nTrack Progress.\nStay Consistent.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Track your workouts, calories, BMI and body weight. "
            "Log every set and rep while FitFlow helps you understand "
            "your weekly fitness progress.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 220,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                "START YOUR JOURNEY",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _heroStat("100%", "Your Data"),
              _heroStat("24/7", "Tracking"),
              _heroStat("Weekly", "Insights"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        children: [
          const Text(
            "EVERYTHING YOU NEED",
            style: TextStyle(
              color: primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Train Smarter With FitFlow",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "One place to track your workouts and monitor your fitness journey.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.5),
          ),
          const SizedBox(height: 35),
          _featureCard(
            Icons.calendar_month_rounded,
            "Workout Calendar",
            "Log your exercises on any date and maintain a complete history of your training sessions.",
          ),
          _featureCard(
            Icons.fitness_center,
            "Sets, Reps & Weight",
            "Record exercises with sets, reps and weights to track your strength progression over time.",
          ),
          _featureCard(
            Icons.monitor_weight_outlined,
            "Weight Tracking",
            "Log your body weight regularly and monitor how your weight changes throughout your journey.",
          ),
          _featureCard(
            Icons.calculate_outlined,
            "BMI Analysis",
            "Calculate and monitor your BMI to better understand your body metrics and fitness status.",
          ),
          _featureCard(
            Icons.local_fire_department_outlined,
            "Calorie Tracking",
            "Keep track of your daily calorie intake and stay aligned with your personal fitness goals.",
          ),
          _featureCard(
            Icons.insights_rounded,
            "Weekly Progress",
            "Get weekly insights based on your workout activity and understand how your performance is improving.",
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: primary, size: 28),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 55),
      child: Column(
        children: [
          const Text(
            "HOW IT WORKS",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Your Progress In 3 Steps",
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _step(
            "01",
            "Create Your Profile",
            "Create your FitFlow account and set up your fitness profile.",
          ),
          _step(
            "02",
            "Log Your Training",
            "Add workouts to your calendar and record exercises, sets, reps and weights.",
          ),
          _step(
            "03",
            "Track Your Progress",
            "Review your weekly progress and monitor improvements in your fitness journey.",
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF166534), Color(0xFF052E16)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, color: Colors.white, size: 45),
          const SizedBox(height: 18),
          const Text(
            "Ready To Start Your\nFitness Journey?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Start tracking your workouts and turn every rep into measurable progress.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF166534),
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text(
              "GET STARTED",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContact() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
      child: Column(
        children: [
          const Text(
            "CONTACT US",
            style: TextStyle(
              color: primary,
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "We're Here To Help",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          _contactItem(Icons.email_outlined, "Email", "rmks1004@gmail.com"),
          _contactItem(
            Icons.language,
            "Website",
            "http://fitflow9.vercel.app/",
          ),
          _contactItem(Icons.location_on_outlined, "Location", "India"),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      color: Colors.black,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, color: primary),
              SizedBox(width: 8),
              Text(
                "FitFlow",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Train. Track. Transform.",
            style: TextStyle(color: Colors.white54),
          ),
          SizedBox(height: 20),
          Divider(color: Colors.white12),
          SizedBox(height: 15),
          Text(
            "© 2026 FitFlow. All rights reserved.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
