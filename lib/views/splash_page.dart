import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:padel_coach/views/status_page.dart';
import '../core/constants/app_assets.dart';
import '../core/services/push_notification_service.dart';
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
  bool _animationDone = false;
  bool _dataReady = false;
  String? _token;
  String? _approvalStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await PushNotificationService().initialize(context);
    });
    _loadData();
  }

  Future<void> _loadData() async {
    _token = await SharedPreferencesUtil().getString('token');
    _approvalStatus = await SharedPreferencesUtil().getString('approval_status');
    _dataReady = true;
    _tryProceed();
  }

  void _tryProceed() {
    if (!_animationDone || !_dataReady || !mounted) return;

    if (_token == null || _token!.isEmpty) {
      PageRouteUtils.pushWithZoom(context, const LoginView());
    } else if (_approvalStatus == 'approved') {
      PageRouteUtils.pushWithZoom(context, const Dashboard());
    } else {
      PageRouteUtils.pushWithZoom(
        context,
        StatusPage(approvalStatus: _approvalStatus ?? 'pending'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8DA60),
      body: Center(
        child: Lottie.asset(
          AppAssets.splash_animation,
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () {
              _animationDone = true;
              _tryProceed();
            });
          },
        ),
      ),
    );
  }
}
