import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fitflow_notifications',
    'FitFlow Notifications',
    description: 'Workout and water reminders',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    await _requestPermission();

    await _initializeLocalNotifications();

    await _initializeFirebaseMessaging();
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notification tapped");
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    final token = await _messaging.getToken();

    debugPrint("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(
        title: message.notification?.title ?? "FitFlow",
        body: message.notification?.body ?? "",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked");
    });
  }

  Future<void> showTestNotification() async {
    await _showNotification(
      title: "FitFlow",
      body: "Notifications are working successfully 🎉",
    );
  }

  Future<void> showWorkoutReminder() async {
    await _showNotification(
      title: "🏋 Workout Reminder",
      body: "Don't break today's streak. Log your workout now!",
    );
  }

  Future<void> showWaterReminder() async {
    await _showNotification(
      title: "💧 Water Reminder",
      body: "Time to drink a glass of water.",
    );
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitflow_notifications',
          'FitFlow Notifications',
          channelDescription: 'Workout and water reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
