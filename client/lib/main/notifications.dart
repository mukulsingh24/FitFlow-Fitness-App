import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  bool isLoading = true;
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<List<dynamic>> _safeCall(Future<List<dynamic>> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return [];
    }
  }

  String _timeAgo(dynamic rawDate) {
    if (rawDate == null) return "";

    final DateTime? parsed = DateTime.tryParse(rawDate.toString());

    if (parsed == null) return "";

    final Duration diff = DateTime.now().difference(parsed);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";

    return "${diff.inDays} days ago";
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    final results = await Future.wait([
      _safeCall(ApiService.getWorkoutHistory),
      _safeCall(ApiService.getBMIHistory),
      _safeCall(ApiService.getCalorieHistory),
    ]);

    final List<dynamic> workouts = results[0];
    final List<dynamic> bmiRecords = results[1];
    final List<dynamic> calorieRecords = results[2];

    final DateTime now = DateTime.now();
    final List<NotificationItem> items = [];

    if (workouts.isEmpty) {
      items.add(
        NotificationItem(
          id: "workout_start",
          title: "Time to Train",
          message:
              "You haven't logged a workout yet. Start your first session today.",
          time: "Now",
          icon: Icons.fitness_center,
        ),
      );
    } else {
      final latestWorkout = workouts.first;
      final DateTime? workoutDate = DateTime.tryParse(
        latestWorkout['workout_date']?.toString() ?? '',
      );

      final bool trainedToday =
          workoutDate != null &&
          workoutDate.year == now.year &&
          workoutDate.month == now.month &&
          workoutDate.day == now.day;

      if (trainedToday) {
        items.add(
          NotificationItem(
            id: "workout_today",
            title: "Nice Work!",
            message:
                "You've already logged a workout today. Keep the momentum going.",
            time: _timeAgo(latestWorkout['created_at']),
            icon: Icons.emoji_events_outlined,
            isRead: true,
          ),
        );
      } else {
        items.add(
          NotificationItem(
            id: "workout_reminder",
            title: "Time to Train",
            message: "Stay consistent. Don't forget to log today's workout.",
            time: "Today",
            icon: Icons.fitness_center,
          ),
        );
      }

      final int recentCount = workouts.where((workout) {
        final DateTime? date = DateTime.tryParse(
          workout['workout_date']?.toString() ?? '',
        );

        if (date == null) return false;

        return now.difference(date).inDays <= 7;
      }).length;

      items.add(
        NotificationItem(
          id: "weekly_progress",
          title: "Weekly Progress",
          message: recentCount > 0
              ? "You've logged $recentCount workout${recentCount == 1 ? '' : 's'} in the past 7 days."
              : "No workouts logged in the past 7 days. Time to get back on track.",
          time: "This week",
          icon: Icons.trending_up,
        ),
      );
    }

    if (bmiRecords.isEmpty) {
      items.add(
        NotificationItem(
          id: "bmi_start",
          title: "Check Your BMI",
          message: "Calculate your BMI to start tracking your body metrics.",
          time: "Now",
          icon: Icons.monitor_weight_outlined,
        ),
      );
    } else {
      final latestBmi = bmiRecords.first;
      final DateTime? recordedAt = DateTime.tryParse(
        latestBmi['created_at']?.toString() ?? '',
      );

      if (recordedAt != null && now.difference(recordedAt).inDays >= 7) {
        items.add(
          NotificationItem(
            id: "bmi_stale",
            title: "Weight Check",
            message: "Update your body weight to keep your progress accurate.",
            time: _timeAgo(latestBmi['created_at']),
            icon: Icons.monitor_weight_outlined,
          ),
        );
      }
    }

    if (calorieRecords.isEmpty) {
      items.add(
        NotificationItem(
          id: "calorie_start",
          title: "Fuel Your Fitness",
          message:
              "Calculate your daily calorie target to plan your nutrition.",
          time: "Now",
          icon: Icons.local_fire_department_outlined,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      notifications = items;
      isLoading = false;
    });
  }

  void markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        foregroundColor: textDark,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                "Read all",
                style: TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: softMint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: primaryDark,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No notifications",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "You're all caught up.",
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: primary,
              onRefresh: _loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      deleteNotification(index);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 25),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF6C6C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          notification.isRead = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: notification.isRead ? surface : softMint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notification.isRead
                                ? border
                                : primary.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: notification.isRead
                                    ? scaffoldBg
                                    : surface,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                notification.icon,
                                color: primaryDark,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: const TextStyle(
                                            color: textDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (!notification.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notification.message,
                                    style: const TextStyle(
                                      color: textMuted,
                                      height: 1.4,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification.time,
                                    style: const TextStyle(
                                      color: textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
