import 'package:flutter/material.dart';

import 'register.dart';
import 'forgot.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adminCodeController = TextEditingController();

  bool _passwordHidden = true;

  // --- Animations ---
  late AnimationController _entranceController;
  late Animation<double> _logoScale;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _card3D;

  late AnimationController _pulseController;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );
    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _card3D = Tween<double>(begin: 0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.25, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    emailController.dispose();
    passwordController.dispose();
    adminCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF020617)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Animated logo ---
                ScaleTransition(
                  scale: _logoScale,
                  child: AnimatedBuilder(
                    animation: _glowPulse,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF059669)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                0xFF22C55E,
                              ).withValues(alpha: _glowPulse.value),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 38,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: _logoScale,
                  child: const Text(
                    'FitFlow',
                    style: TextStyle(
                      fontSize: 34,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _cardFade,
                  child: const Text(
                    'Welcome back, athlete.',
                    style: TextStyle(color: Colors.white60, fontSize: 15),
                  ),
                ),

                // --- 3D card entrance ---
                AnimatedBuilder(
                  animation: _card3D,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_card3D.value),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _buildLoginCard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _passwordHidden,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _passwordHidden = !_passwordHidden),
              icon: Icon(
                _passwordHidden ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotScreen()),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.15)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('or', style: TextStyle(color: Colors.white38)),
              ),
              Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Admin section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.08),
                  Colors.amber.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.amber,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Admin access',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: adminCodeController,
                  label: 'Admin passcode',
                  icon: Icons.vpn_key_outlined,
                  obscure: true,
                  accentColor: Colors.amber,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Login as admin',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New to FitFlow? ',
                style: TextStyle(color: Colors.white54),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Create account',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    Color accentColor = const Color(0xFF22C55E),
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}
