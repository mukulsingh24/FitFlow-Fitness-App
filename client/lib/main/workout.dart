import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight; // 0 = bodyweight

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });
}

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // ---- Palette (matches the rest of the app) ----
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);
  static const Color danger = Color(0xFFEF6C6C);

  final List<Exercise> exercises = [];

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  String get formattedDuration {
    // Rough estimate: ~2.5 minutes per set, including rest.
    final int minutes = (totalSets * 2.5).round();
    if (minutes < 60) return "${minutes}m";
    final int hours = minutes ~/ 60;
    final int remaining = minutes % 60;
    return remaining == 0 ? "${hours}h" : "${hours}h ${remaining}m";
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      exercises.add(exercise);
    });
  }

  void _deleteExercise(String id) {
    setState(() {
      exercises.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Workout",
              style: TextStyle(
                color: textDark,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "Track every set and every rep",
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkoutHeader(),
              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's Workout",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (exercises.isNotEmpty)
                    Text(
                      "${exercises.length} exercise${exercises.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                        color: primaryDark,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Your exercises for today's training session.",
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),

              exercises.isEmpty
                  ? _buildEmptyWorkout()
                  : Column(
                      children: exercises
                          .map((e) => _buildExerciseCard(e))
                          .toList(),
                    ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddExerciseSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    "ADD EXERCISE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Workout Summary",
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _WorkoutStat(
                      icon: Icons.fitness_center,
                      value: "${exercises.length}",
                      title: "Exercises",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WorkoutStat(
                      icon: Icons.repeat_rounded,
                      value: "$totalSets",
                      title: "Sets",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WorkoutStat(
                      icon: Icons.timer_outlined,
                      value: exercises.isEmpty ? "0m" : formattedDuration,
                      title: "Duration",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    final DateTime now = DateTime.now();

    final List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: softMint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: primaryDark,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercises.isEmpty ? "Ready to train?" : "Keep it going!",
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${months[now.month - 1]} ${now.day}, ${now.year}",
                  style: const TextStyle(color: textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt_rounded, color: primaryDark, size: 28),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Dismissible(
      key: ValueKey(exercise.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteExercise(exercise.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: softMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_gymnastics_rounded,
                color: primaryDark,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.weight > 0
                        ? "${exercise.sets} sets × ${exercise.reps} reps · ${exercise.weight.toStringAsFixed(exercise.weight % 1 == 0 ? 0 : 1)} kg"
                        : "${exercise.sets} sets × ${exercise.reps} reps · Bodyweight",
                    style: const TextStyle(color: textMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swipe_left_alt_rounded, color: border, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWorkout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: scaffoldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_outlined,
              color: textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No exercises added",
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Start your workout by adding your first exercise.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddExerciseSheet(),
    ).then((result) {
      if (result != null && result is Exercise) {
        _addExercise(result);
      }
    });
  }
}

class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet();

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color border = Color(0xFFE7ECE8);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController(text: "3");
  final TextEditingController repsController = TextEditingController(
    text: "10",
  );
  final TextEditingController weightController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final exercise = Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      sets: int.parse(setsController.text.trim()),
      reps: int.parse(repsController.text.trim()),
      weight: weightController.text.trim().isEmpty
          ? 0
          : double.parse(weightController.text.trim()),
    );

    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Add Exercise",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Log the exercise, sets, reps and weight used.",
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),

                _buildField(
                  controller: nameController,
                  label: "Exercise Name",
                  hint: "e.g. Bench Press",
                  icon: Icons.fitness_center_rounded,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter an exercise name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: setsController,
                        label: "Sets",
                        hint: "3",
                        icon: Icons.repeat_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final int? n = int.tryParse(v ?? "");
                          if (n == null || n <= 0 || n > 20) {
                            return "1-20";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: repsController,
                        label: "Reps",
                        hint: "10",
                        icon: Icons.format_list_numbered_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final int? n = int.tryParse(v ?? "");
                          if (n == null || n <= 0 || n > 100) {
                            return "1-100";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildField(
                  controller: weightController,
                  label: "Weight (kg) — optional",
                  hint: "Leave empty for bodyweight",
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final double? n = double.tryParse(v.trim());
                    if (n == null || n < 0 || n > 500) {
                      return "Enter a valid weight";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "SAVE EXERCISE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryDark, size: 20),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: Color(0xFFB6C0BA), fontSize: 12.5),
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
}

class _WorkoutStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _WorkoutStat({
    required this.icon,
    required this.value,
    required this.title,
  });

  static const Color primaryDark = Color(0xFF128C3F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color border = Color(0xFFE7ECE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryDark, size: 21),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(color: textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
