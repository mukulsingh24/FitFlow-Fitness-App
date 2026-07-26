import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final String time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
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
  IconData _getIcon(String type) {
    switch (type) {
      case "workout":
        return Icons.fitness_center;

      case "water":
        return Icons.water_drop;

      case "weight":
        return Icons.monitor_weight;

      case "bmi":
        return Icons.monitor_weight_outlined;

      case "calorie":
        return Icons.local_fire_department;

      case "profile":
        return Icons.person;

      case "login":
        return Icons.login;

      case "welcome":
        return Icons.celebration;

      default:
        return Icons.notifications;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
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
    setState(() => isLoading = true);

    try {
      final data = await ApiService.getNotifications();

      notifications = data
          .map<NotificationItem>(
            (e) => NotificationItem(
              id: e["id"],
              title: e["title"],
              message: e["message"],
              type: e["type"],
              time: _timeAgo(e["created_at"]),
              isRead: e["is_read"],
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> markAllAsRead() async {
    await ApiService.markAllNotificationsRead();

    for (final n in notifications) {
      n.isRead = true;
    }

    setState(() {});
  }

  Future<void> deleteNotification(int index) async {
    await ApiService.deleteNotification(notifications[index].id);

    notifications.removeAt(index);

    setState(() {});
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
                    onDismissed: (_) async {
                      await deleteNotification(index);
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
                      onTap: () async {
                        await ApiService.markNotificationRead(notification.id);

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
                                _getIcon(notification.type),
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
