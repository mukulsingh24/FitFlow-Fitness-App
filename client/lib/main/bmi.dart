import 'package:flutter/material.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController heightController = TextEditingController();

  final TextEditingController weightController = TextEditingController();

  double? bmi;
  String bmiCategory = "";

  static const Color primary = Color(0xFF22C55E);
  static const Color darkBg = Color(0xFF020617);
  static const Color cardBg = Color(0xFF111827);

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void calculateBMI() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double height = double.parse(heightController.text.trim()) / 100;

    final double weight = double.parse(weightController.text.trim());

    final double result = weight / (height * height);

    String category;

    if (result < 18.5) {
      category = "Underweight";
    } else if (result < 25) {
      category = "Normal Weight";
    } else if (result < 30) {
      category = "Overweight";
    } else {
      category = "Obese";
    }

    setState(() {
      bmi = result;
      bmiCategory = category;
    });
  }

  void resetCalculator() {
    heightController.clear();
    weightController.clear();

    setState(() {
      bmi = null;
      bmiCategory = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 30),

                        _buildCalculatorCard(),

                        if (bmi != null) ...[
                          const SizedBox(height: 22),
                          _buildResultCard(),
                        ],

                        const SizedBox(height: 22),

                        _buildBmiGuide(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF052E16), Color(0xFF020617)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 100,
              right: -40,
              child: Transform.rotate(
                angle: -0.3,
                child: Icon(
                  Icons.fitness_center,
                  size: 180,
                  color: Colors.white.withOpacity(0.035),
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              left: -50,
              child: Transform.rotate(
                angle: 0.4,
                child: Icon(
                  Icons.sports_gymnastics,
                  size: 190,
                  color: primary.withOpacity(0.035),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),

          const SizedBox(width: 5),

          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            "FitFlow",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.25)),
            ),
            child: const Text(
              "BMI",
              style: TextStyle(color: primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.18), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KNOW YOUR BODY",
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "BMI Calculator",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Track your body metrics and stay focused on your fitness goals.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 15),

          Icon(Icons.monitor_weight_outlined, color: primary, size: 55),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Your Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "We'll calculate your Body Mass Index.",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),

            const SizedBox(height: 22),

            _buildInput(
              controller: heightController,
              label: "Height",
              hint: "Enter height",
              suffix: "cm",
              icon: Icons.height,
            ),

            const SizedBox(height: 17),

            _buildInput(
              controller: weightController,
              label: "Weight",
              hint: "Enter weight",
              suffix: "kg",
              icon: Icons.monitor_weight_outlined,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.calculate_outlined),
                label: const Text(
                  "CALCULATE BMI",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: primary),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
        suffixStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color(0xFF020617),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label cannot be empty";
        }

        final double? number = double.tryParse(value.trim());

        if (number == null || number <= 0) {
          return "Enter a valid $label";
        }

        if (label == "Height" && number > 300) {
          return "Enter a valid height in cm";
        }

        if (label == "Weight" && number > 500) {
          return "Enter a valid weight in kg";
        }

        return null;
      },
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF166534), Color(0xFF052E16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: primary, size: 32),

          const SizedBox(height: 12),

          const Text(
            "YOUR BMI",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            bmi!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 58,
              fontWeight: FontWeight.w900,
            ),
          ),

          Text(
            bmiCategory,
            style: const TextStyle(
              color: primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          TextButton.icon(
            onPressed: resetCalculator,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Calculate Again",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primary),
              SizedBox(width: 10),
              Text(
                "BMI Guide",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          BmiGuideRow(category: "Underweight", range: "Below 18.5"),

          BmiGuideRow(category: "Normal Weight", range: "18.5 - 24.9"),

          BmiGuideRow(category: "Overweight", range: "25.0 - 29.9"),

          BmiGuideRow(category: "Obese", range: "30.0+"),
        ],
      ),
    );
  }
}

class BmiGuideRow extends StatelessWidget {
  final String category;
  final String range;

  const BmiGuideRow({super.key, required this.category, required this.range});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              category,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          Text(
            range,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
