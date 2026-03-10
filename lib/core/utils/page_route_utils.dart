import 'package:flutter/material.dart';

class PageRouteUtils {
  static Future<T?> push<T extends Object?>(BuildContext context, Widget page) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context, Widget page, {TO? result}) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => page), result: result);
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
      BuildContext context, Widget page,
      {bool Function(Route<dynamic>)? predicate}) {
    return Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => page),
        predicate ?? (route) => false);
  }

  static Future<T?> pushWithSlide<T extends Object?>(BuildContext context, Widget page,
      {Duration duration = const Duration(milliseconds: 300),
      Offset begin = const Offset(1, 0)}) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: begin, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: duration,
      ),
    );
  }

  static Future<T?> pushWithZoom<T extends Object?>(BuildContext context, Widget page,
      {Duration duration = const Duration(milliseconds: 300)}) {
    return Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            ScaleTransition(scale: animation, child: child),
        transitionDuration: duration,
      ),
    );
  }
}
