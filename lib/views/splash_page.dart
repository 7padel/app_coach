import 'package:flutter/material.dart';
import 'package:padel_coach/views/status_page.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/page_route_utils.dart';
import '../core/utils/shared_preferences_util.dart';
import 'dashboard.dart';
import 'login_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() async {
    final token = await SharedPreferencesUtil().getString('token');
    final approvalStatus = await SharedPreferencesUtil().getString('approval_status');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      PageRouteUtils.pushWithZoom(context, const LoginView());
    } else if (approvalStatus == 'approved') {
      PageRouteUtils.pushWithZoom(context, const Dashboard());
    } else {
      PageRouteUtils.pushWithZoom(
        context,
        StatusPage(approvalStatus: approvalStatus ?? 'pending'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_tennis, size: 80, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              '7Padel Coach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
