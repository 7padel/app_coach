import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppUtils {
  static void showToast(String message, {Color backgroundColor = AppColors.secondary}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.black,
    );
  }
}
