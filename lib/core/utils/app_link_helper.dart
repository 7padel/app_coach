import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:padel_coach/core/utils/shared_preferences_util.dart';
import 'package:padel_coach/views/dashboard.dart';
import 'package:padel_coach/views/booking_history_page.dart';

import '../../main.dart';

class AppLinkHelper {
  static final _appLinks = AppLinks();

  static Future<void> init() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      final retryLink = await _appLinks.getInitialLink();
      if (retryLink != null) {
        _handleLink(retryLink);
      }
    } catch (e) {
      debugPrint('AppLink cold start failed: $e');
    }

    // Live stream
    _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  /// Navigate to a deep link URL (e.g. from a push notification).
  static Future<void> navigate(String deepLink) async {
    try {
      await _handleLink(Uri.parse(deepLink));
    } catch (e) {
      debugPrint('AppLinkHelper.navigate failed: $e');
    }
  }

  static Future<void> _handleLink(Uri uri) async {
    debugPrint('AppLink Received: $uri');
    final token = await SharedPreferencesUtil().getString('token');
    if (token == null || token.isEmpty) return;

    final path = uri.path;

    // /home or / — navigate to schedule
    if (path == '/home' || path == '/') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Dashboard()),
        (Route<dynamic> route) => false,
      );

    // /schedule — navigate to schedule (home) tab
    } else if (path == '/schedule') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Dashboard()),
        (Route<dynamic> route) => false,
      );

    // /bookings or /history — navigate to booking history
    } else if (path == '/bookings' || path == '/history') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Dashboard()),
        (Route<dynamic> route) => false,
      );
      // Push booking history on top
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
      );

    // /profile — navigate to profile tab
    } else if (path == '/profile') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Dashboard(initialTab: 1)),
        (Route<dynamic> route) => false,
      );

    // Default — go to dashboard
    } else {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Dashboard()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
