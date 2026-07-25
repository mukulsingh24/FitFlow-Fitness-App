import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login.dart';
import 'personal_information.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primary = Color(0xFF1DB954);
  // static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  // static const Color border = Color(0xFFE7ECE8);
  static const Color danger = Color(0xFFEF6C6C);
  bool _isLoading = true;
  String _name = "";
  String _email = "";
  String? _gender;
  DateTime? _dateOfBirth;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse('https://fitflow9.vercel.app/');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch website');
    }
  }

  Future<void> _contactUs() async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'rmks1004@gmail.com',
      queryParameters: {'subject': 'FitFlow Support'},
    );

    if (!await launchUrl(email)) {
      throw Exception('Could not open email app');
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        _name = profile['name']?.toString() ?? 'FitFlow User';
        _email = profile['email']?.toString() ?? '';
        _gender = profile['gender']?.toString();

        if (profile['date_of_birth'] != null) {
          _dateOfBirth = DateTime.parse(profile['date_of_birth']);
        }

        _photoUrl = firebaseUser?.photoURL;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  int _calculateAge() {
    if (_dateOfBirth == null) return 0;

    final today = DateTime.now();

    int age = today.year - _dateOfBirth!.year;

    if (today.month < _dateOfBirth!.month ||
        (today.month == _dateOfBirth!.month && today.day < _dateOfBirth!.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile",
              style: TextStyle(
                color: textDark,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "Manage your account and preferences",
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: softMint,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: surface,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: primary,
                            backgroundImage: _photoUrl != null
                                ? NetworkImage(_photoUrl!)
                                : null,
                            child: _photoUrl == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          _name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dateOfBirth == null
                              ? (_gender ?? "")
                              : "${_calculateAge()} Years"
                                    "${_gender != null ? " • $_gender" : ""}",
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Account",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Manage your personal and fitness information.",
                      style: TextStyle(color: textMuted, fontSize: 12.5),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _ProfileOption(
                    icon: Icons.person_outline_rounded,
                    title: "Personal Information",
                    subtitle: "Manage your personal details",
                    onTap: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalInformationScreen(),
                        ),
                      );

                      if (updated == true) {
                        _loadProfile();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "FitFlow",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _ProfileOption(
                    icon: Icons.language_rounded,
                    title: "Visit FitFlow Website",
                    subtitle: "Open the official FitFlow website",
                    onTap: (_openWebsite),
                  ),
                  const SizedBox(height: 16),
                  _ProfileOption(
                    icon: Icons.mail_outline_rounded,
                    title: "Contact Us",
                    subtitle: "Get in touch with the FitFlow team",
                    onTap: (_contactUs),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => logout(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: danger,
                        backgroundColor: surface,
                        side: const BorderSide(color: danger, width: 1.2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        "LOGOUT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color primaryDark = Color(0xFF128C3F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: softMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryDark, size: 22),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
