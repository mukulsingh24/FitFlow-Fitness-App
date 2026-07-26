import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/notification_service.dart';

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
    'Preacher Biceps Curl',
    'Rope/Bar Pushdown',
    'Skull Crushers',
    'Preacher Hammer Curl',
    'Overhead Tricep Extension',
    'Reverse Grip Curl',
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
  'Shoulder': [
    'Shoulder Press',
    'Overhead Press',
    'Dumbbell Shoulder Press',
    'Arnold Press',
    'Lateral Raises',
    'Front Raises',
    'Cable Lateral Raise',
    'Machine Shoulder Press',
    'Shrugs',
  ],

  'Rest': ['Rest Day Log'],
};

class WorkoutScreen extends StatefulWidget {
  final Map<String, dynamic>? workoutToEdit;
  final bool isEditing;

  const WorkoutScreen({super.key, this.workoutToEdit, this.isEditing = false});

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
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  final List<WorkoutExercise> exercises = [];
  List<dynamic> workoutHistory = [];
  bool isLoadingHistory = true;
  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
    if (widget.isEditing && widget.workoutToEdit != null) {
      _loadWorkoutForEditing();
    }
  }

  void _loadWorkoutForEditing() {
    final workout = widget.workoutToEdit!;

    selectedSplit = workout['split'];
    selectedWorkoutDay = workout['workout_day'];
    selectedDate = DateTime.parse(workout['workout_date']);

    exercises.clear();

    final exerciseList = workout['exercises'] as List;

    for (final exercise in exerciseList) {
      final sets = exercise['sets'] as List;

      exercises.add(
        WorkoutExercise(
          id: exercise['id'].toString(),
          name: exercise['name'],
          workoutDay: selectedWorkoutDay,
          sets: sets.length,
          reps: sets.first['reps'],
          workingWeight: (sets.first['weight'] as num?)?.toDouble() ?? 0,
          isCustom: false,
        ),
      );
    }
  }

  int get currentStreak {
    if (workoutDates.isEmpty) return 0;

    final today = DateTime.now();
    DateTime current = DateTime(today.year, today.month, today.day);

    if (!workoutDates.contains(current)) {
      current = current.subtract(const Duration(days: 1));

      if (!workoutDates.contains(current)) {
        return 0;
      }
    }

    int streak = 0;

    while (workoutDates.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      final history = await ApiService.getWorkoutHistory();

      if (!mounted) return;

      setState(() {
        workoutHistory = history;
        isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint('WORKOUT HISTORY ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  Set<DateTime> get workoutDates {
    return workoutHistory.map<DateTime>((workout) {
      final date = DateTime.parse(workout['workout_date']);
      return DateTime(date.year, date.month, date.day);
    }).toSet();
  }

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

  Widget _buildWorkoutHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Workouts',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Review your recently completed workouts.',
          style: TextStyle(color: textMuted, fontSize: 12.5),
        ),

        const SizedBox(height: 16),

        if (isLoadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (workoutHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: const Column(
              children: [
                Icon(Icons.history_rounded, color: textMuted, size: 30),
                SizedBox(height: 10),
                Text(
                  'No workouts yet',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Complete your first workout to see it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...workoutHistory.take(5).map((workout) {
            final exerciseList = workout['exercises'] as List? ?? [];

            int totalSets = 0;

            for (final exercise in exerciseList) {
              final sets = exercise['sets'] as List? ?? [];

              totalSets += sets.length;
            }

            return InkWell(
              onTap: () {
                _showWorkoutDetails(workout);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
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
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: primaryDark,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout['workout_day']?.toString() ?? 'Workout',
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${exerciseList.length} exercises'
                            ' • $totalSets sets',
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            workout['workout_date']?.toString() ?? '',
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: textMuted,
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutScreen(
                                isEditing: true,
                                workoutToEdit: workout,
                              ),
                            ),
                          );

                          if (updated == true) {
                            await _loadWorkoutHistory();
                          }
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Workout'),
                                content: const Text(
                                  'Are you sure you want to delete this workout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              await ApiService.deleteWorkout(workout['id']);
                              await NotificationService.instance
                                  .showWorkoutDeleted();
                              await _loadWorkoutHistory();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Workout deleted successfully'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete workout: $e'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showWorkoutDetails(dynamic workout) {
    final List<dynamic> exerciseList = workout['exercises'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: softMint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: primaryDark,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${workout['workout_day'] ?? 'Workout'} Workout',
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                workout['workout_date']?.toString() ?? '',
                                style: const TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Divider(color: border, height: 1),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(22),
                      itemCount: exerciseList.length,
                      itemBuilder: (context, index) {
                        final exercise = exerciseList[index];

                        final List<dynamic> sets =
                            exercise['sets'] as List? ?? [];

                        return _buildWorkoutDetailExercise(
                          exercise['name']?.toString() ?? 'Exercise',
                          sets,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkoutDetailExercise(String exerciseName, List<dynamic> sets) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scaffoldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: primaryDark,
                size: 19,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  exerciseName,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(
                child: Text(
                  'SET',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'WEIGHT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'REPS',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...sets.map((set) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;

            final weightText = weight > 0
                ? '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg'
                : 'Bodyweight';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${set['set_number'] ?? '-'}',
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      weightText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      '${set['reps'] ?? '-'}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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

  void _editExercise(int index) {
    _showAddExerciseSheet(context, exercise: exercises[index], index: index);
  }

  Future<void> _finishWorkout() async {
    if (exercises.isEmpty) {
      return;
    }

    try {
      final workoutExercises = exercises.map((exercise) {
        return {
          'name': exercise.name,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'working_weight': exercise.workingWeight,
        };
      }).toList();

      if (widget.isEditing) {
        await ApiService.updateWorkout(
          id: widget.workoutToEdit!['id'],
          split: selectedSplit,
          workoutDay: selectedWorkoutDay,
          workoutDate: selectedDate,
          exercises: workoutExercises,
        );
        await NotificationService.instance.showWorkoutUpdated();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout updated successfully!'),
            backgroundColor: primaryDark,
          ),
        );

        Navigator.pop(context, true);
      } else {
        final result = await ApiService.saveWorkout(
          split: selectedSplit,
          workoutDay: selectedWorkoutDay,
          workoutDate: selectedDate,
          exercises: workoutExercises,
        );
        await NotificationService.instance.showWorkoutSaved();
        debugPrint('WORKOUT SAVED: $result');
        await _loadWorkoutHistory();
        if (!mounted) return;
        setState(() {
          exercises.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout saved successfully!'),
            backgroundColor: primaryDark,
          ),
        );
      }
    } catch (e) {
      debugPrint('WORKOUT SAVE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save workout: $e'),
          backgroundColor: danger,
        ),
      );
    }
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
            dropdownColor: surface,
            style: const TextStyle(
              color: textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: textMuted,
            ),
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: primary, width: 1.6),
              ),
            ),
            items: workoutSplits.keys
                .map(
                  (split) => DropdownMenuItem<String>(
                    value: split,
                    child: Text(split, style: const TextStyle(color: textDark)),
                  ),
                )
                .toList(),
            onChanged: _changeSplit,
          ),

          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            key: ValueKey(selectedSplit),
            initialValue: selectedWorkoutDay,
            dropdownColor: surface,
            style: const TextStyle(
              color: textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: textMuted,
            ),
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: primary, width: 1.6),
              ),
            ),
            items: availableWorkoutDays
                .map(
                  (day) => DropdownMenuItem<String>(
                    value: day,
                    child: Text(day, style: const TextStyle(color: textDark)),
                  ),
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
        title: Column(
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Track every set and every rep",
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: softMint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "🔥 $currentStreak",
                    style: const TextStyle(
                      color: primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
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
              _buildWorkoutCalendar(),
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
                      children: exercises.asMap().entries.map((entry) {
                        return _buildExerciseCard(entry.value, entry.key);
                      }).toList(),
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
                    label: Text(
                      widget.isEditing ? 'UPDATE WORKOUT' : 'FINISH WORKOUT',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
              _buildWorkoutHistory(),
              const SizedBox(height: 30),
              _buildWorkoutGuidance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCalendar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            eventLoader: (day) {
              final normalized = DateTime(day.year, day.month, day.day);

              if (workoutDates.contains(normalized)) {
                return ['workout'];
              }

              return [];
            },
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDate = selected;
                focusedDay = focused;
              });
            },
            daysOfWeekHeight: 22,
            rowHeight: 42,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                return Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text('🔥', style: TextStyle(fontSize: 12)),
                  ),
                );
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: EdgeInsets.only(bottom: 12),
              titleTextStyle: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: primaryDark,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: primaryDark,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
              weekendStyle: TextStyle(
                color: textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 1,
              cellMargin: EdgeInsets.all(4),
              defaultTextStyle: TextStyle(
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
              weekendTextStyle: TextStyle(
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
              todayDecoration: BoxDecoration(
                color: primaryDark,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: primaryDark,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "Today",
                style: TextStyle(color: textMuted, fontSize: 11.5),
              ),
              const SizedBox(width: 18),
              const Text('🔥', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 6),
              const Text(
                "Workout logged",
                style: TextStyle(color: textMuted, fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int index) {
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

            IconButton(
              icon: const Icon(Icons.edit_outlined, color: primaryDark),
              onPressed: () {
                _editExercise(index);
              },
            ),
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

  void _showAddExerciseSheet(
    BuildContext context, {
    WorkoutExercise? exercise,
    int? index,
  }) {
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
        exercise: exercise,
      ),
    ).then((result) {
      if (result != null && result is WorkoutExercise) {
        setState(() {
          if (index == null) {
            exercises.add(result);
          } else {
            exercises[index] = result;
          }
        });
      }
    });
  }
}

class _AddExerciseSheet extends StatefulWidget {
  final String workoutDay;
  final List<String> availableExercises;
  final WorkoutExercise? exercise;

  const _AddExerciseSheet({
    required this.workoutDay,
    required this.availableExercises,
    this.exercise,
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

    if (widget.exercise != null) {
      final e = widget.exercise!;

      selectedExercise = e.name;
      isCustomExercise = e.isCustom;

      if (e.isCustom) {
        customExerciseController.text = e.name;
      }

      setsController.text = e.sets.toString();
      repsController.text = e.reps.toString();

      if (e.workingWeight > 0) {
        weightController.text = e.workingWeight.toString();
      }
    } else {
      if (widget.availableExercises.isNotEmpty) {
        selectedExercise = widget.availableExercises.first;
      }
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
      id:
          widget.exercise?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
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
                    dropdownColor: surface,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textMuted,
                    ),
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
                          child: Text(
                            exercise,
                            style: const TextStyle(color: textDark),
                          ),
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
                      child: Text(
                        widget.exercise == null
                            ? 'ADD TO WORKOUT'
                            : 'UPDATE EXERCISE',
                        style: const TextStyle(
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
