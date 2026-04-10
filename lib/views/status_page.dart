import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/page_route_utils.dart';
import '../core/utils/shared_preferences_util.dart';
import 'login_view.dart';

class StatusPage extends StatelessWidget {
  final String approvalStatus;

  const StatusPage({super.key, required this.approvalStatus});

  @override
  Widget build(BuildContext context) {
    final isPending = approvalStatus == 'pending';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPending
                      ? AppColors.pending.withOpacity(0.2)
                      : AppColors.rejected.withOpacity(0.2),
                ),
                child: Icon(
                  isPending ? Icons.hourglass_top_rounded : Icons.cancel_outlined,
                  size: 52,
                  color: isPending ? AppColors.pending : AppColors.rejected,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isPending ? AppStrings.pending_approval : 'Registration Not Approved',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPending
                    ? AppStrings.pending_message
                    : AppStrings.rejected_message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    await SharedPreferencesUtil().clear();
                    if (context.mounted) {
                      PageRouteUtils.pushAndRemoveUntil(context, const LoginView());
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Login', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
