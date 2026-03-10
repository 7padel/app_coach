import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;

  const Button({super.key, required this.onPressed, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.secondary,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.white24,
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
