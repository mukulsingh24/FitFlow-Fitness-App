import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  List<dynamic> bmiHistory = [];
  bool isLoadingHistory = true;

  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  static const Color underweightColor = Color(0xFF3B9FE0);
  static const Color normalColor = Color(0xFF1DB954);
  static const Color overweightColor = Color(0xFFF5A524);
  static const Color obeseColor = Color(0xFFEF6C6C);

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadBMIHistory();
  }

  Future<void> loadBMIHistory() async {
    try {
      final history = await ApiService.getBMIHistory();

      if (!mounted) return;

      setState(() {
        bmiHistory = history;
        isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint("BMI HISTORY ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  Future<void> calculateBMI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double heightCm = double.parse(heightController.text.trim());

    final double weight = double.parse(weightController.text.trim());

    // Calculate BMI locally first
    final double heightM = heightCm / 100;
    final double localBmi = weight / (heightM * heightM);

    String category;

    if (localBmi < 18.5) {
      category = "Underweight";
    } else if (localBmi < 25) {
      category = "Normal Weight";
    } else if (localBmi < 30) {
      category = "Overweight";
    } else {
      category = "Obese";
    }

    setState(() {
      bmi = localBmi;
      bmiCategory = category;
    });
    try {
      await ApiService.saveBMI(weight: weight, heightCm: heightCm);

      // Refresh BMI history after successful save
      await loadBMIHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("BMI saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("BMI SAVE ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("BMI calculated, but could not be saved: $e"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void resetCalculator() {
    heightController.clear();
    weightController.clear();

    setState(() {
      bmi = null;
      bmiCategory = "";
    });
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "Underweight":
        return underweightColor;
      case "Normal Weight":
        return normalColor;
      case "Overweight":
        return overweightColor;
      case "Obese":
        return obeseColor;
      default:
        return primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCalculatorCard(),
                    if (bmi != null) ...[
                      const SizedBox(height: 20),
                      _buildResultCard(),
                    ],
                    const SizedBox(height: 20),
                    _buildBMIHistory(),
                    const SizedBox(height: 24),
                    _buildBmiGuide(),
                    const SizedBox(height: 24),
                  ],
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
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: textDark,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "FitFlow",
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: softMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "BMI",
              style: TextStyle(
                color: primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: softMint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -10,
            child: Icon(
              Icons.monitor_weight_outlined,
              size: 90,
              color: primary.withOpacity(0.14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "KNOW YOUR BODY",
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "BMI Calculator",
                style: TextStyle(
                  color: textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Track your body metrics and stay focused on your fitness goals.",
                style: TextStyle(color: textMuted, fontSize: 13.5, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Your Details",
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "We'll calculate your Body Mass Index.",
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildInput(
              controller: heightController,
              label: "Height",
              hint: "Enter height",
              suffix: "cm",
              icon: Icons.height_rounded,
            ),
            const SizedBox(height: 16),
            _buildInput(
              controller: weightController,
              label: "Weight",
              hint: "Enter weight",
              suffix: "kg",
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 24),
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
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
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
      style: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: primaryDark, size: 20),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: Color(0xFFB6C0BA)),
        suffixStyle: const TextStyle(
          color: primaryDark,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: scaffoldBg,
        errorStyle: const TextStyle(color: Color(0xFFEF6C6C), fontSize: 11.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF6C6C)),
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
    final Color categoryColor = _categoryColor(bmiCategory);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 10),
          const Text(
            "YOUR BMI",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bmi!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              bmiCategory,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: resetCalculator,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              "Calculate Again",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIHistory() {
    if (isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bmiHistory.isEmpty) {
      return const Center(
        child: Text(
          "No BMI history yet",
          style: TextStyle(color: textMuted, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "BMI History",
          style: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Track how your BMI changes over time.",
          style: TextStyle(color: textMuted, fontSize: 13),
        ),

        const SizedBox(height: 16),

        ...bmiHistory.map((record) {
          final double bmiValue = (record['bmi'] as num).toDouble();

          final double weight = (record['weight'] as num).toDouble();

          final String date =
              record['created_at']?.toString().split('T').first ?? "";

          String category;

          if (bmiValue < 18.5) {
            category = "Underweight";
          } else if (bmiValue < 25) {
            category = "Normal Weight";
          } else if (bmiValue < 30) {
            category = "Overweight";
          } else {
            category = "Obese";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.monitor_weight_outlined,
                    color: primaryDark,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BMI ${bmiValue.toStringAsFixed(1)}",
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "$category • ${weight.toStringAsFixed(1)} kg",
                        style: const TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Text(
                  date,
                  style: const TextStyle(color: textMuted, fontSize: 11),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBmiGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: softMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "BMI Guide",
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BmiGuideRow(
            category: "Underweight",
            range: "Below 18.5",
            color: underweightColor,
            highlighted: bmiCategory == "Underweight",
          ),
          BmiGuideRow(
            category: "Normal Weight",
            range: "18.5 - 24.9",
            color: normalColor,
            highlighted: bmiCategory == "Normal Weight",
          ),
          BmiGuideRow(
            category: "Overweight",
            range: "25.0 - 29.9",
            color: overweightColor,
            highlighted: bmiCategory == "Overweight",
          ),
          BmiGuideRow(
            category: "Obese",
            range: "30.0+",
            color: obeseColor,
            highlighted: bmiCategory == "Obese",
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class BmiGuideRow extends StatelessWidget {
  final String category;
  final String range;
  final Color color;
  final bool highlighted;
  final bool isLast;

  const BmiGuideRow({
    super.key,
    required this.category,
    required this.range,
    required this.color,
    this.highlighted = false,
    this.isLast = false,
  });

  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? softMint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                color: highlighted ? textDark : textMuted,
                fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            range,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
