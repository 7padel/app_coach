import 'package:flutter/material.dart';
import 'core/utils/app_link_helper.dart';
import 'views/splash_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoachApp());
  Future.delayed(Duration.zero, () {
    AppLinkHelper.init();
  });
}

class CoachApp extends StatelessWidget {
  const CoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: '7Padel Coach',
      theme: ThemeData(
        fontFamily: 'HelveticaNeue',
        textTheme: const TextTheme(),
      ),
      home: const SplashPage(),
    );
  }
}
