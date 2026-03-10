import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'views/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoachApp());
}

class CoachApp extends StatelessWidget {
  const CoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '7Padel Coach',
      theme: ThemeData(
        fontFamily: 'HelveticaNeue',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: false,
      ),
      home: const SplashPage(),
    );
  }
}
