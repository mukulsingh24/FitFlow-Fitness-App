import 'package:flutter/material.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController feetController = TextEditingController();
  final TextEditingController inchesController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // ---- Palette (matches HomeScreen) ----
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);
  static const Color proteinColor = Color(0xFF1DB954);
  static const Color carbColor = Color(0xFFF5A524);
  static const Color fatColor = Color(0xFFEF6C6C);

  String selectedGender = "Male";
  String selectedActivity = "Moderately Active";
  String selectedGoal = "Maintain Weight";

  bool isCalculating = false;
  double? maintenanceCalories;
  double? targetCalories;
  double? bmrValue;

  late final AnimationController _entrance;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  final List<_ActivityOption> activityOptions = const [
    _ActivityOption(
      label: "Sedentary",
      description: "Little or no exercise",
      icon: Icons.chair_alt_outlined,
      multiplier: 1.2,
    ),
    _ActivityOption(
      label: "Lightly Active",
      description: "Light exercise 1–3 days/week",
      icon: Icons.directions_walk_rounded,
      multiplier: 1.375,
    ),
    _ActivityOption(
      label: "Moderately Active",
      description: "Moderate exercise 3–5 days/week",
      icon: Icons.directions_run_rounded,
      multiplier: 1.55,
    ),
    _ActivityOption(
      label: "Very Active",
      description: "Hard exercise 6–7 days/week",
      icon: Icons.sports_gymnastics_rounded,
      multiplier: 1.725,
    ),
    _ActivityOption(
      label: "Extra Active",
      description: "Very hard exercise & physical job",
      icon: Icons.bolt_rounded,
      multiplier: 1.9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _headerFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_headerFade);

    _cardFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_cardFade);

    _entrance.forward();
  }

  @override
  void dispose() {
    ageController.dispose();
    feetController.dispose();
    inchesController.dispose();
    weightController.dispose();
    _scrollController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  double get _activityMultiplier {
    return activityOptions
        .firstWhere((a) => a.label == selectedActivity)
        .multiplier;
  }

  Future<void> calculateCalories() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isCalculating = true);

    // Brief tactile delay so the button press feels responsive rather than instant.
    await Future.delayed(const Duration(milliseconds: 500));

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

    final double maintenance = bmr * _activityMultiplier;

    double target = maintenance;
    if (selectedGoal == "Lose Weight") {
      target = maintenance - 500;
    } else if (selectedGoal == "Gain Weight") {
      target = maintenance + 500;
    }

    // Keep the target within a safe, realistic floor.
    if (target < 1200) target = 1200;

    if (!mounted) return;

    setState(() {
      bmrValue = bmr;
      maintenanceCalories = maintenance;
      targetCalories = target;
      isCalculating = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
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
      bmrValue = null;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
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
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeader(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _buildCalculatorCard(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      transitionBuilder: (child, animation) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        );
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.92,
                              end: 1.0,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                      child: targetCalories != null
                          ? _buildResultCard(key: const ValueKey("result"))
                          : const SizedBox.shrink(key: ValueKey("empty")),
                    ),
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

  // ---------------- APP BAR ----------------

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
              "CALORIES",
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

  // ---------------- HEADER ----------------

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
              Icons.local_fire_department_rounded,
              size: 90,
              color: primary.withOpacity(0.14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "FUEL YOUR FITNESS",
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Calorie Calculator",
                style: TextStyle(
                  color: textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Estimate your daily calorie needs based on your body and activity level.",
                style: TextStyle(color: textMuted, fontSize: 13.5, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- FORM CARD ----------------

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
              "Your Details",
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            _buildNumberInput(
              controller: ageController,
              label: "Age",
              hint: "e.g. 25",
              icon: Icons.cake_outlined,
              validator: (value) {
                final int? age = int.tryParse(value ?? "");
                if (age == null) return "Enter your age";
                if (age < 15 || age > 80) return "Age must be 15–80";
                return null;
              },
            ),

            const SizedBox(height: 18),
            _sectionLabel("Gender"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildGenderButton("Male", Icons.male_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderButton("Female", Icons.female_rounded),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _sectionLabel("Height"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    controller: feetController,
                    label: "Feet",
                    hint: "5",
                    icon: Icons.height_rounded,
                    validator: (value) {
                      final int? feet = int.tryParse(value ?? "");
                      if (feet == null || feet < 3 || feet > 8) {
                        return "3–8 only";
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
                    icon: Icons.straighten_rounded,
                    validator: (value) {
                      final int? inches = int.tryParse(value ?? "");
                      if (inches == null || inches < 0 || inches > 11) {
                        return "0–11 only";
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
              hint: "e.g. 165",
              icon: Icons.monitor_weight_outlined,
              allowDecimal: true,
              validator: (value) {
                final double? weight = double.tryParse(value ?? "");
                if (weight == null || weight < 60 || weight > 660) {
                  return "Enter a weight between 60–660 lbs";
                }
                return null;
              },
            ),

            const SizedBox(height: 22),
            _sectionLabel("Activity Level"),
            const SizedBox(height: 10),
            _buildActivitySelector(),

            const SizedBox(height: 22),
            _sectionLabel("Fitness Goal"),
            const SizedBox(height: 10),
            _buildGoalSelector(),

            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isCalculating ? null : calculateCalories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isCalculating
                      ? const SizedBox(
                          key: ValueKey("loading"),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          key: ValueKey("label"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "CALCULATE CALORIES",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: textMuted,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    final bool selected = selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => selectedGender = gender),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected ? softMint : scaffoldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primary : border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primaryDark : textMuted),
            const SizedBox(height: 5),
            Text(
              gender,
              style: TextStyle(
                color: selected ? primaryDark : textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Column(
      children: activityOptions.map((option) {
        final bool selected = selectedActivity == option.label;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => setState(() => selectedActivity = option.label),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? softMint : scaffoldBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? primary : border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: selected ? primary : surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      option.icon,
                      size: 18,
                      color: selected ? Colors.white : textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            color: selected ? primaryDark : textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.description,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: selected ? 1 : 0,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelector() {
    final goals = [
      ("Lose Weight", Icons.trending_down_rounded),
      ("Maintain Weight", Icons.horizontal_rule_rounded),
      ("Gain Weight", Icons.trending_up_rounded),
    ];

    return Row(
      children: goals.map((goal) {
        final label = goal.$1;
        final icon = goal.$2;
        final bool selected = selectedGoal == label;
        final bool isLast = label == goals.last.$1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: InkWell(
              onTap: () => setState(() => selectedGoal = label),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? primary : scaffoldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? primary : border),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected ? Colors.white : textMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label.replaceAll(" Weight", ""),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
      style: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryDark, size: 20),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: Color(0xFFB6C0BA)),
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
      validator: validator,
    );
  }

  // ---------------- RESULT ----------------

  Widget _buildResultCard({Key? key}) {
    final double target = targetCalories!;
    final double maintenance = maintenanceCalories!;
    final double bmr = bmrValue!;

    // Macro split: 30% protein, 40% carbs, 30% fat.
    final int proteinG = ((target * 0.30) / 4).round();
    final int carbsG = ((target * 0.40) / 4).round();
    final int fatG = ((target * 0.30) / 9).round();

    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text(
            "YOUR DAILY CALORIE TARGET",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            key: ValueKey(target),
            tween: Tween<double>(begin: 0, end: target),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                "${value.round()} kcal",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            selectedGoal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: _statColumn("BMR", "${bmr.round()}", "kcal")),
                Container(width: 1, height: 34, color: Colors.white24),
                Expanded(
                  child: _statColumn(
                    "Maintenance",
                    "${maintenance.round()}",
                    "kcal",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Suggested Macros",
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 12),
                _macroRow("Protein", proteinG, 0.30, proteinColor),
                const SizedBox(height: 10),
                _macroRow("Carbs", carbsG, 0.40, carbColor),
                const SizedBox(height: 10),
                _macroRow("Fat", fatG, 0.30, fatColor),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "This is an estimate based on the Mifflin-St Jeor formula. Individual needs can vary.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _statColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: " $unit",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _macroRow(String label, int grams, double fraction, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: scaffoldBg),
                  TweenAnimationBuilder<double>(
                    key: ValueKey("$label-$fraction"),
                    tween: Tween<double>(begin: 0, end: fraction),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        widthFactor: value.clamp(0, 1),
                        alignment: Alignment.centerLeft,
                        child: Container(color: color),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Text(
            "${grams}g",
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: textDark,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityOption {
  final String label;
  final String description;
  final IconData icon;
  final double multiplier;

  const _ActivityOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.multiplier,
  });
}
