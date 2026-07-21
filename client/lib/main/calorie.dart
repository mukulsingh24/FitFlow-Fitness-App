import 'package:flutter/material.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController feetController = TextEditingController();
  final TextEditingController inchesController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  static const Color primary = Color(0xFF22C55E);
  static const Color darkBg = Color(0xFF020617);
  static const Color cardBg = Color(0xFF111827);

  String selectedGender = "Male";
  String selectedActivity = "Moderately Active";
  String selectedGoal = "Maintain Weight";

  double? maintenanceCalories;
  double? targetCalories;

  final Map<String, double> activityLevels = {
    "Sedentary": 1.2,
    "Lightly Active": 1.375,
    "Moderately Active": 1.55,
    "Very Active": 1.725,
    "Extra Active": 1.9,
  };

  @override
  void dispose() {
    ageController.dispose();
    feetController.dispose();
    inchesController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void calculateCalories() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int age = int.parse(ageController.text.trim());
    final double feet = double.parse(feetController.text.trim());
    final double inches = double.parse(inchesController.text.trim());
    final double weightPounds = double.parse(weightController.text.trim());

    final double totalInches = (feet * 12) + inches;
    final double heightCm = totalInches * 2.54;
    final double weightKg = weightPounds * 0.453592;

    double bmr;

    if (selectedGender == "Male") {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    final double activityMultiplier = activityLevels[selectedActivity]!;

    final double maintenance = bmr * activityMultiplier;

    double target = maintenance;

    if (selectedGoal == "Lose Weight") {
      target = maintenance - 500;
    } else if (selectedGoal == "Gain Weight") {
      target = maintenance + 500;
    }

    setState(() {
      maintenanceCalories = maintenance;
      targetCalories = target;
    });
  }

  void resetCalculator() {
    ageController.clear();
    feetController.clear();
    inchesController.clear();
    weightController.clear();

    setState(() {
      selectedGender = "Male";
      selectedActivity = "Moderately Active";
      selectedGoal = "Maintain Weight";
      maintenanceCalories = null;
      targetCalories = null;
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
                        const SizedBox(height: 25),
                        _buildCalculatorCard(),

                        if (targetCalories != null) ...[
                          const SizedBox(height: 25),
                          _buildResultCard(),
                        ],

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
              top: 120,
              right: -45,
              child: Transform.rotate(
                angle: -0.3,
                child: Icon(
                  Icons.local_fire_department,
                  size: 190,
                  color: primary.withOpacity(0.035),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -50,
              child: Transform.rotate(
                angle: 0.3,
                child: Icon(
                  Icons.fitness_center,
                  size: 180,
                  color: Colors.white.withOpacity(0.035),
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
              "CALORIES",
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.18), Colors.transparent],
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
                  "FUEL YOUR FITNESS",
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Calorie Calculator",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Estimate your daily calorie needs based on your body and activity level.",
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
          Icon(Icons.local_fire_department, color: primary, size: 55),
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
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 22),

            _buildNumberInput(
              controller: ageController,
              label: "Age",
              hint: "15 - 80",
              icon: Icons.cake_outlined,
              validator: (value) {
                final int? age = int.tryParse(value ?? "");

                if (age == null) {
                  return "Enter your age";
                }

                if (age < 15 || age > 80) {
                  return "Age must be between 15 and 80";
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            const Text(
              "Gender",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildGenderButton("Male", Icons.male)),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderButton("Female", Icons.female)),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Height",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    controller: feetController,
                    label: "Feet",
                    hint: "5",
                    icon: Icons.height,
                    validator: (value) {
                      final int? feet = int.tryParse(value ?? "");

                      if (feet == null || feet < 3 || feet > 8) {
                        return "Invalid feet";
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildNumberInput(
                    controller: inchesController,
                    label: "Inches",
                    hint: "10",
                    icon: Icons.straighten,
                    validator: (value) {
                      final int? inches = int.tryParse(value ?? "");

                      if (inches == null || inches < 0 || inches > 11) {
                        return "0 - 11 only";
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _buildNumberInput(
              controller: weightController,
              label: "Weight (pounds)",
              hint: "165",
              icon: Icons.monitor_weight_outlined,
              allowDecimal: true,
              validator: (value) {
                final double? weight = double.tryParse(value ?? "");

                if (weight == null || weight <= 0) {
                  return "Enter a valid weight";
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildDropdown(
              label: "Activity Level",
              value: selectedActivity,
              items: activityLevels.keys.toList(),
              icon: Icons.directions_run,
              onChanged: (value) {
                setState(() {
                  selectedActivity = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            _buildDropdown(
              label: "Fitness Goal",
              value: selectedGoal,
              items: const ["Lose Weight", "Maintain Weight", "Gain Weight"],
              icon: Icons.flag_outlined,
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: calculateCalories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.local_fire_department),
                label: const Text(
                  "CALCULATE CALORIES",
                  style: TextStyle(
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

  Widget _buildGenderButton(String gender, IconData icon) {
    final bool selected = selectedGender == gender;

    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.15) : darkBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? primary : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primary : Colors.white54),
            const SizedBox(height: 5),
            Text(
              gender,
              style: TextStyle(
                color: selected ? primary : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool allowDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primary),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: darkBg,
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
          borderSide: const BorderSide(color: primary),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: cardBg,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primary),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: darkBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF166534), Color(0xFF052E16)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department, color: primary, size: 40),

          const SizedBox(height: 12),

          const Text(
            "YOUR DAILY CALORIE TARGET",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "${targetCalories!.round()} kcal",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            selectedGoal,
            style: const TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  "Estimated Maintenance",
                  style: TextStyle(color: Colors.white60),
                ),

                const SizedBox(height: 5),

                Text(
                  "${maintenanceCalories!.round()} kcal/day",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "This is an estimate. Individual calorie needs can vary.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),

          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: resetCalculator,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Calculate Again",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
