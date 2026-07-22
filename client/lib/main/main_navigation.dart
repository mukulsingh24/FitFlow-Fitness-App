import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'health.dart';
import 'workout.dart';
import 'activity.dart';
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
    HealthScreen(),
    WorkoutScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 72,
          backgroundColor: const Color(0xFF0F172A),
          indicatorColor: const Color(0xFF22C55E).withOpacity(0.18),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }

            return const TextStyle(color: Colors.white54, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white54),
              selectedIcon: Icon(Icons.home, color: Color(0xFF22C55E)),
              label: "Home",
            ),

            NavigationDestination(
              icon: Icon(Icons.favorite_border, color: Colors.white54),
              selectedIcon: Icon(Icons.favorite, color: Color(0xFF22C55E)),
              label: "Health",
            ),

            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, color: Colors.white54),
              selectedIcon: Icon(
                Icons.fitness_center,
                color: Color(0xFF22C55E),
              ),
              label: "Workout",
            ),

            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: Colors.white54),
              selectedIcon: Icon(
                Icons.calendar_month,
                color: Color(0xFF22C55E),
              ),
              label: "Activity",
            ),

            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white54),
              selectedIcon: Icon(Icons.person, color: Color(0xFF22C55E)),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
