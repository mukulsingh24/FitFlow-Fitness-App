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
    description: 'FitFlow Notifications',
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
      showNotification(
        title: message.notification?.title ?? "FitFlow",
        body: message.notification?.body ?? "",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked");
    });
  }

  Future<void> showNotification({
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
          channelDescription: 'FitFlow Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showWelcomeNotification() async {
    await showNotification(
      title: "🎉 Welcome to FitFlow",
      body: "Your fitness journey starts today!",
    );
  }

  Future<void> showLoginSuccess() async {
    await showNotification(
      title: "👋 Welcome Back",
      body: "Let's achieve today's fitness goals!",
    );
  }

  Future<void> showWorkoutSaved() async {
    await showNotification(
      title: "💪 Workout Saved",
      body: "Awesome! Keep your streak alive.",
    );
  }

  Future<void> showWorkoutUpdated() async {
    await showNotification(
      title: "✏️ Workout Updated",
      body: "Your workout has been updated successfully.",
    );
  }

  Future<void> showWorkoutDeleted() async {
    await showNotification(
      title: "🗑️ Workout Deleted",
      body: "The workout has been removed.",
    );
  }

  Future<void> showWaterLogged() async {
    await showNotification(
      title: "💧 Water Logged",
      body: "Great! Keep yourself hydrated.",
    );
  }

  Future<void> showCaloriesUpdated() async {
    await showNotification(
      title: "🔥 Calories Updated",
      body: "Your calorie intake has been saved.",
    );
  }

  Future<void> showWeightUpdated() async {
    await showNotification(
      title: "⚖️ Weight Updated",
      body: "Your latest weight has been recorded.",
    );
  }

  Future<void> showBMIUpdated() async {
    await showNotification(
      title: "📊 BMI Updated",
      body: "Your BMI has been calculated successfully.",
    );
  }

  Future<void> showTestNotification() async {
    await showNotification(
      title: "FitFlow",
      body: "Notifications are working successfully 🎉",
    );
  }

  Future<void> showProfileUpdated() async {
    await showNotification(
      title: "👤 Profile Updated",
      body: "Your personal information has been updated successfully.",
    );
  }
}
