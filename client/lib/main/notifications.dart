import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  bool isRead;

  NotificationItem({
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

  final List<NotificationItem> notifications = [
    NotificationItem(
      title: "Time to Train",
      message: "Stay consistent. Don't forget to log today's workout.",
      time: "10 min ago",
      icon: Icons.fitness_center,
    ),
    NotificationItem(
      title: "Weekly Progress",
      message: "Your weekly fitness progress is ready to review.",
      time: "2 hours ago",
      icon: Icons.trending_up,
    ),
    NotificationItem(
      title: "Weight Check",
      message: "Update your body weight to keep your progress accurate.",
      time: "Yesterday",
      icon: Icons.monitor_weight_outlined,
      isRead: true,
    ),
  ];

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
          TextButton(
            onPressed: markAllAsRead,
            child: const Text(
              "Read all",
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return Dismissible(
                  key: ValueKey("${notification.title}$index"),
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
                              color: notification.isRead ? scaffoldBg : surface,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(notification.icon, color: primaryDark),
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
    );
  }
}
