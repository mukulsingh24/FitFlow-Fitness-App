import 'package:flutter/material.dart';
import '../admin/dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final adminIdController = TextEditingController();
  final passcodeController = TextEditingController();

  bool hidePasscode = true;
  final String adminId = "admin";
  final String adminPasscode = "1234567890";

  @override
  void dispose() {
    adminIdController.dispose();
    passcodeController.dispose();
    super.dispose();
  }

  void adminLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (adminIdController.text.trim() == "admin" &&
        passcodeController.text == adminPasscode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Admin ID or Passcode"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Color(0xFF22C55E),
                      size: 55,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Admin Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Access the FitFlow administration panel",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Admin ID",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: adminIdController,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration(
                    hint: "Enter Admin ID",
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Admin ID is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  "Admin Passcode",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: passcodeController,
                  obscureText: hidePasscode,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: "Enter Admin Passcode",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF64748B),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePasscode = !hidePasscode;
                        });
                      },
                      icon: Icon(
                        hidePasscode
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF22C55E),
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Admin passcode is required";
                    }

                    if (value != adminPasscode) {
                      return "Incorrect Admin Passcode";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: adminLogin,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      "Admin Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Back to User Login"),
                ),

                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.security_outlined, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "This area is restricted to authorized FitFlow administrators only.",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
