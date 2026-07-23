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

  //static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);

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
      backgroundColor: scaffoldBg,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 68,
              backgroundColor: surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              indicatorColor: softMint,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: primaryDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  );
                }

                return const TextStyle(
                  color: textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                );
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
                  icon: Icon(Icons.home_outlined, color: textMuted),
                  selectedIcon: Icon(Icons.home_rounded, color: primaryDark),
                  label: "Home",
                ),

                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded, color: textMuted),
                  selectedIcon: Icon(
                    Icons.favorite_rounded,
                    color: primaryDark,
                  ),
                  label: "Health",
                ),

                NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined, color: textMuted),
                  selectedIcon: Icon(
                    Icons.fitness_center_rounded,
                    color: primaryDark,
                  ),
                  label: "Workout",
                ),

                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined, color: textMuted),
                  selectedIcon: Icon(
                    Icons.calendar_month_rounded,
                    color: primaryDark,
                  ),
                  label: "Activity",
                ),

                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: textMuted),
                  selectedIcon: Icon(Icons.person_rounded, color: primaryDark),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
