import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  static const Color primary = Color(0xFF22C55E);
  static const Color background = Color(0xFF020617);
  static const Color cardColor = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Activity",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Your consistency and workout history",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakSection(),

              const SizedBox(height: 28),

              const Text(
                "Workout Calendar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Select a date to view your workout activity.",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 18),

              _buildCalendar(now),

              const SizedBox(height: 28),

              const Text(
                "This Week",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _buildWeeklyProgress(),

              const SizedBox(height: 28),

              const Row(
                children: [
                  Text(
                    "Recent Workouts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.history, color: Colors.white38),
                ],
              ),

              const SizedBox(height: 15),

              _buildEmptyHistory(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF052E16), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: primary,
              size: 35,
            ),
          ),

          const SizedBox(width: 18),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Streak",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  "0 Days",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Complete workouts to build your streak.",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "BEST",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "0",
                style: TextStyle(
                  color: primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "days",
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(DateTime now) {
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final int firstWeekday = DateTime(now.year, now.month, 1).weekday;

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: primary),

              const SizedBox(width: 10),

              Text(
                "${months[now.month - 1]} ${now.year}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left, color: Colors.white38),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, color: Colors.white38),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Row(
            children: [
              _DayLabel("M"),
              _DayLabel("T"),
              _DayLabel("W"),
              _DayLabel("T"),
              _DayLabel("F"),
              _DayLabel("S"),
              _DayLabel("S"),
            ],
          ),

          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstWeekday - 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox();
              }

              final int day = index - firstWeekday + 2;

              final bool isToday = day == now.day;

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white60,
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: primary, size: 8),
              SizedBox(width: 6),
              Text(
                "Today",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              SizedBox(width: 18),
              Icon(Icons.circle, color: Colors.white24, size: 8),
              SizedBox(width: 6),
              Text(
                "Workout completed",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Weekly Goal",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Spacer(),

              Text(
                "0 / 5 workouts",
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 9,
              backgroundColor: Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),

          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekDay("M", false),
              _WeekDay("T", false),
              _WeekDay("W", false),
              _WeekDay("T", false),
              _WeekDay("F", false),
              _WeekDay("S", false),
              _WeekDay("S", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, color: Colors.white30, size: 42),

          SizedBox(height: 12),

          Text(
            "No workouts yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Complete your first workout and your activity history will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String day;

  const _DayLabel(this.day);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String day;
  final bool completed;

  const _WeekDay(this.day, this.completed);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completed
                ? const Color(0xFF22C55E)
                : const Color(0xFF1E293B),
            shape: BoxShape.circle,
          ),
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : const Icon(
                  Icons.circle_outlined,
                  color: Colors.white24,
                  size: 14,
                ),
        ),

        const SizedBox(height: 6),

        Text(day, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
