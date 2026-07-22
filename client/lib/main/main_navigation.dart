import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'workout_calendar.dart';
import 'progress.dart';
import 'profile.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WorkoutCalendarScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFF22C55E),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.fitness_center, color: Colors.white),
            label: "Workout",
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up, color: Colors.white70),
            selectedIcon: Icon(Icons.insights, color: Colors.white),
            label: "Progress",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white70),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
