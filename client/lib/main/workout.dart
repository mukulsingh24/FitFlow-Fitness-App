import 'package:flutter/material.dart';

class WorkoutExercise {
  final String id;
  final String name;
  final String workoutDay;
  final int sets;
  final int reps;
  final double workingWeight;
  final bool isCustom;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.workoutDay,
    required this.sets,
    required this.reps,
    required this.workingWeight,
    this.isCustom = false,
  });

  WorkoutExercise copyWith({
    String? name,
    String? workoutDay,
    int? sets,
    int? reps,
    double? workingWeight,
    bool? isCustom,
  }) {
    return WorkoutExercise(
      id: id,
      name: name ?? this.name,
      workoutDay: workoutDay ?? this.workoutDay,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      workingWeight: workingWeight ?? this.workingWeight,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

const Map<String, List<String>> workoutSplits = {
  'Push Pull Legs': ['Push', 'Pull', 'Legs'],
  'Body Part Split': ['Chest', 'Back', 'Arms', 'Abs', 'Rest'],
};

const Map<String, List<String>> exerciseLibrary = {
  'Push': [
    'Bench Press',
    'Incline Dumbbell Press',
    'Machine Shoulder Press',
    'Dumbbell Lateral Raises',
    'Rope Pushdown',
    'Overhead Tricep Extension',
    'Chest Fly',
    'Push Ups',
  ],

  'Pull': [
    'Wide Grip Lat Pulldown',
    'Seated Cable Row',
    'Chest Supported Row',
    'EZ Bar Curl',
    'Wrist Twist',
    'Face Pull',
    'Hammer Curl',
    'Pull Ups',
  ],

  'Legs': [
    'Squat',
    'Wide Stance Leg Press',
    'Leg Extension',
    'Weighted Lunges',
    'Calf Raises',
    'Leg Curl',
    'Romanian Deadlift',
    'Hip Thrust',
  ],

  'Chest': [
    'Bench Press',
    'Incline Dumbbell Press',
    'Decline Bench Press',
    'Chest Press Machine',
    'Cable Fly',
    'Pec Deck',
    'Push Ups',
  ],

  'Back': [
    'Lat Pulldown',
    'Seated Cable Row',
    'Barbell Row',
    'Chest Supported Row',
    'Single Arm Dumbbell Row',
    'Pull Ups',
    'Face Pull',
  ],

  'Arms': [
    'Barbell Curl',
    'Dumbbell Curl',
    'Hammer Curl',
    'Preacher Curl',
    'Rope Pushdown',
    'Skull Crushers',
    'Overhead Tricep Extension',
  ],

  'Abs': [
    'Crunches',
    'Cable Crunch',
    'Leg Raises',
    'Hanging Leg Raises',
    'Plank',
    'Russian Twist',
    'Ab Wheel Rollout',
  ],

  // REST
  'Rest': [],
};

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);
  static const Color danger = Color(0xFFEF6C6C);

  String selectedSplit = 'Push Pull Legs';
  String selectedWorkoutDay = 'Push';

  final List<WorkoutExercise> exercises = [];

  List<String> get availableWorkoutDays {
    return workoutSplits[selectedSplit] ?? [];
  }

  List<String> get availableExercises {
    return exerciseLibrary[selectedWorkoutDay] ?? [];
  }

  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  }

  int get totalReps {
    return exercises.fold(
      0,
      (sum, exercise) => sum + (exercise.sets * exercise.reps),
    );
  }

  void _finishWorkout() {
    if (exercises.isEmpty) {
      return;
    }

    // Temporary local implementation.
    // Next step: replace this with FastAPI saveWorkout().
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$selectedWorkoutDay workout ready to save'),
        backgroundColor: primaryDark,
      ),
    );
  }

  Widget _buildWorkoutGuidance() {
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
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: primaryDark),
              SizedBox(width: 10),
              Text(
                'Workout Guidance',
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildGuidanceItem(
            icon: Icons.verified_outlined,
            title: 'Form First',
            description:
                'Prioritize proper technique before increasing weight.',
          ),

          _buildGuidanceItem(
            icon: Icons.trending_up_rounded,
            title: 'Progressive Overload',
            description:
                'Gradually improve your weight, reps, or overall performance.',
          ),

          _buildGuidanceItem(
            icon: Icons.battery_5_bar_rounded,
            title: 'Keep Reps in Reserve',
            description:
                'Aim to finish most working sets with about 2–3 good reps left.',
          ),

          _buildGuidanceItem(
            icon: Icons.timer_outlined,
            title: 'Rest & Recovery',
            description:
                'Take sufficient rest between sets and prioritize recovery between sessions.',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem({
    required IconData icon,
    required String title,
    required String description,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: softMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryDark, size: 19),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (showDivider) ...[
          const SizedBox(height: 14),
          const Divider(color: border, height: 1),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  void _changeSplit(String? split) {
    if (split == null) return;

    final days = workoutSplits[split];

    if (days == null || days.isEmpty) return;

    setState(() {
      selectedSplit = split;
      selectedWorkoutDay = days.first;

      exercises.clear();
    });
  }

  void _changeWorkoutDay(String? day) {
    if (day == null) return;

    setState(() {
      selectedWorkoutDay = day;
      exercises.clear();
    });
  }

  void _addExercise(WorkoutExercise exercise) {
    setState(() {
      exercises.add(exercise);
    });
  }

  void _deleteExercise(String id) {
    setState(() {
      exercises.removeWhere((exercise) => exercise.id == id);
    });
  }

  Widget _buildTrainingSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training Plan',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Choose your workout split and today\'s training.',
            style: TextStyle(color: textMuted, fontSize: 12.5),
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            initialValue: selectedSplit,
            decoration: InputDecoration(
              labelText: 'Workout Split',
              prefixIcon: const Icon(
                Icons.account_tree_outlined,
                color: primaryDark,
              ),
              filled: true,
              fillColor: scaffoldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: border),
              ),
            ),
            items: workoutSplits.keys
                .map(
                  (split) => DropdownMenuItem<String>(
                    value: split,
                    child: Text(split),
                  ),
                )
                .toList(),
            onChanged: _changeSplit,
          ),

          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            key: ValueKey(selectedSplit),
            initialValue: selectedWorkoutDay,
            decoration: InputDecoration(
              labelText: 'Today\'s Training',
              prefixIcon: const Icon(
                Icons.fitness_center_rounded,
                color: primaryDark,
              ),
              filled: true,
              fillColor: scaffoldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: border),
              ),
            ),
            items: availableWorkoutDays
                .map(
                  (day) =>
                      DropdownMenuItem<String>(value: day, child: Text(day)),
                )
                .toList(),
            onChanged: _changeWorkoutDay,
          ),
        ],
      ),
    );
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
              const SizedBox(height: 20),
              _buildTrainingSelector(),
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
                ],
              ),
              const SizedBox(height: 24),

              if (selectedWorkoutDay != 'Rest')
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: exercises.isEmpty ? null : _finishWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: border,
                      disabledForegroundColor: textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text(
                      'FINISH WORKOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              _buildWorkoutGuidance(),

              const SizedBox(height: 30),
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

  Widget _buildExerciseCard(WorkoutExercise exercise) {
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
                    exercise.workingWeight > 0
                        ? "${exercise.sets} sets × "
                              "${exercise.reps} reps · "
                              "${exercise.workingWeight.toStringAsFixed(exercise.workingWeight % 1 == 0 ? 0 : 1)} kg"
                        : "${exercise.sets} sets × "
                              "${exercise.reps} reps · Bodyweight",
                    style: const TextStyle(color: textMuted, fontSize: 12.5),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 13,
                        color: primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.workoutDay,
                        style: const TextStyle(
                          color: primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (exercise.isCustom) ...[
                        const SizedBox(width: 8),
                        const Text(
                          "• Custom",
                          style: TextStyle(color: textMuted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
    if (selectedWorkoutDay == 'Rest') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rest day selected. Recovery is part of your training.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExerciseSheet(
        workoutDay: selectedWorkoutDay,
        availableExercises: availableExercises,
      ),
    ).then((result) {
      if (result != null && result is WorkoutExercise) {
        _addExercise(result);
      }
    });
  }
}

class _AddExerciseSheet extends StatefulWidget {
  final String workoutDay;
  final List<String> availableExercises;

  const _AddExerciseSheet({
    required this.workoutDay,
    required this.availableExercises,
  });

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

  final TextEditingController customExerciseController =
      TextEditingController();

  final TextEditingController setsController = TextEditingController(text: '3');

  final TextEditingController repsController = TextEditingController(
    text: '10',
  );

  final TextEditingController weightController = TextEditingController();

  String? selectedExercise;

  bool isCustomExercise = false;

  @override
  void initState() {
    super.initState();

    if (widget.availableExercises.isNotEmpty) {
      selectedExercise = widget.availableExercises.first;
    }
  }

  @override
  void dispose() {
    customExerciseController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String exerciseName;

    if (isCustomExercise) {
      exerciseName = customExerciseController.text.trim();
    } else {
      if (selectedExercise == null) {
        return;
      }

      exerciseName = selectedExercise!;
    }

    final exercise = WorkoutExercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: exerciseName,
      workoutDay: widget.workoutDay,
      sets: int.parse(setsController.text.trim()),
      reps: int.parse(repsController.text.trim()),
      workingWeight: weightController.text.trim().isEmpty
          ? 0
          : double.parse(weightController.text.trim()),
      isCustom: isCustomExercise,
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
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
                    'Add Exercise',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${widget.workoutDay} Workout',
                    style: const TextStyle(
                      color: primaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    initialValue: isCustomExercise
                        ? 'Custom Exercise'
                        : selectedExercise,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Exercise',
                      prefixIcon: const Icon(
                        Icons.fitness_center_rounded,
                        color: primaryDark,
                      ),
                      filled: true,
                      fillColor: scaffoldBg,
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
                        borderSide: const BorderSide(
                          color: primary,
                          width: 1.6,
                        ),
                      ),
                    ),
                    items: [
                      ...widget.availableExercises.map(
                        (exercise) => DropdownMenuItem<String>(
                          value: exercise,
                          child: Text(exercise),
                        ),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'Custom Exercise',
                        child: Text(
                          '+ Custom Exercise',
                          style: TextStyle(
                            color: primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        if (value == 'Custom Exercise') {
                          isCustomExercise = true;
                          selectedExercise = null;
                        } else {
                          isCustomExercise = false;
                          selectedExercise = value;
                          customExerciseController.clear();
                        }
                      });
                    },
                  ),

                  if (isCustomExercise) ...[
                    const SizedBox(height: 14),

                    _buildField(
                      controller: customExerciseController,
                      label: 'Custom Exercise Name',
                      hint: 'e.g. Dumbbell Pullover',
                      icon: Icons.edit_outlined,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (!isCustomExercise) {
                          return null;
                        }

                        if (value == null || value.trim().isEmpty) {
                          return 'Enter an exercise name';
                        }

                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: setsController,
                          label: 'Sets',
                          hint: '3',
                          icon: Icons.repeat_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final number = int.tryParse(value ?? '');

                            if (number == null || number <= 0 || number > 20) {
                              return '1-20';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildField(
                          controller: repsController,
                          label: 'Reps',
                          hint: '10',
                          icon: Icons.format_list_numbered_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final number = int.tryParse(value ?? '');

                            if (number == null || number <= 0 || number > 100) {
                              return '1-100';
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
                    label: 'Working Weight (kg)',
                    hint: 'Leave empty for bodyweight',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }

                      final number = double.tryParse(value.trim());

                      if (number == null || number < 0 || number > 500) {
                        return 'Enter a valid weight';
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
                        'ADD TO WORKOUT',
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
