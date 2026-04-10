import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:padel_coach/core/constants/app_config.dart';
import 'package:padel_coach/core/utils/shared_preferences_util.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('Notification permission not granted');
      return;
    }

    // Init local notifications
    await _initLocalNotifications();

    // Get FCM token and register
    final String? fcmToken = await _firebaseMessaging.getToken();
    debugPrint('Coach FCM Token: $fcmToken');
    if (fcmToken != null) {
      await SharedPreferencesUtil().saveString('fcm_token', fcmToken);
      await _registerTokenWithBackend(fcmToken);
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    // Terminated state tap
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    // Token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await SharedPreferencesUtil().saveString('fcm_token', newToken);
      await _registerTokenWithBackend(newToken);
    });
  }

  /// Call after login to ensure token is registered
  Future<void> registerSavedToken() async {
    String? token = await SharedPreferencesUtil().getString('fcm_token');
    if (token == null || token.isEmpty) {
      token = await _firebaseMessaging.getToken();
      if (token != null) {
        await SharedPreferencesUtil().saveString('fcm_token', token);
      }
    }
    if (token != null && token.isNotEmpty) {
      debugPrint('Registering coach FCM token: ${token.substring(0, 20)}...');
      await _registerTokenWithBackend(token);
    } else {
      debugPrint('No FCM token available for coach');
    }
  }

  Future<void> _registerTokenWithBackend(String fcmToken) async {
    try {
      final authToken = await SharedPreferencesUtil().getString('token');
      if (authToken == null || authToken.isEmpty) return;

      final deviceType = Platform.isIOS ? 'ios' : 'android';
      final dio = Dio();
      await dio.post(
        '${AppConfig.baseUrl}coaches/push-token',
        data: {'token': fcmToken, 'device_type': deviceType},
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
          validateStatus: (_) => true,
        ),
      );
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          final data = Map<String, dynamic>.from(jsonDecode(payload));
          _handleNotificationTap(data);
        }
      },
    );

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'General Notifications',
        description: 'Coach app notifications',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'General Notifications',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
              contentTitle: notification.title,
            ),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Coach notification tapped: $data');
    // Navigate to relevant screen based on data type
    // For now, just go to dashboard
  }
}
