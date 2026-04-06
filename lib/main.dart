import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/utils/app_link_helper.dart';
import 'views/splash_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
