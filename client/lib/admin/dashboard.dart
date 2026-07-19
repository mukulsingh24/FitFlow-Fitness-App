import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          "FitFlow Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text(
          "Welcome Admin!",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
