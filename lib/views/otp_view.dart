import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:padel_coach/views/status_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/page_route_utils.dart';
import '../core/utils/shared_preferences_util.dart';
import '../models/verify_otp_response.dart';
import '../core/services/push_notification_service.dart';
import '../viewmodels/otp_view_model.dart';
import '../widgets/button.dart';
import 'dashboard.dart';

class OtpView extends StatelessWidget {
  final String phoneNo;
  final String otp;

  const OtpView({super.key, required this.phoneNo, required this.otp});

  @override
  Widget build(BuildContext context) {
    return BaseView<OtpViewModel>(
      model: OtpViewModel(),
      onModelReady: (model) async {
        model.startResendTimer();
        if (otp.isNotEmpty) {
          model.setOtp(otp);
          final response = await model.verifyOtp(context, phoneNo);
          if (response != null && context.mounted) {
            await _handleSuccess(context, response);
          }
        }
      },
      builder: (context, model, _) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  AppAssets.bg_otp,
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.05, 0.11, 0.41, 0.53, 0.83, 1.0],
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.5),
                        Color.fromRGBO(0, 0, 0, 0.0),
                        Color.fromRGBO(0, 0, 0, 0.71),
                        Color.fromRGBO(0, 0, 0, 0.85),
                        Color.fromRGBO(0, 0, 0, 1.0),
                        Color.fromRGBO(0, 0, 0, 1.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OTP Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          text: 'Enter the code from the SMS we sent \n to ',
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: '+91 $phoneNo',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(text: '  '),
                            TextSpan(
                              text: 'Edit',
                              style: const TextStyle(color: AppColors.secondary),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      PinCodeTextField(
                        controller: model.otpController,
                        appContext: context,
                        length: 6,
                        onChanged: model.onOtpChanged,
                        onCompleted: model.onOtpCompleted,
                        autoFocus: true,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 55,
                          fieldWidth: 45,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white,
                          selectedColor: Colors.white,
                        ),
                        textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text("Didn't receive OTP? ",
                              style: TextStyle(color: Colors.white70)),
                          model.secondsRemaining > 0
                              ? Text('Resend in ${model.secondsRemaining}s',
                                  style: const TextStyle(color: Colors.white))
                              : GestureDetector(
                                  onTap: () => model.resendOtp(context, phoneNo),
                                  child: const Text('Resend OTP',
                                      style: TextStyle(color: AppColors.secondary)),
                                ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      model.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Button(
                              onPressed: () async {
                                final response = await model.verifyOtp(context, phoneNo);
                                if (response != null && context.mounted) {
                                  await _handleSuccess(context, response);
                                }
                              },
                              text: AppStrings.submit,
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSuccess(BuildContext context, VerifyOtpResponse response) async {
    if (response.status != true || response.data == null) return;

    final data = response.data!;
    await SharedPreferencesUtil().saveString('token', data.token ?? '');
    await SharedPreferencesUtil().saveString('approval_status', data.approvalStatus ?? 'pending');
    await SharedPreferencesUtil().saveString('coach_name', data.fullName ?? '');

    // Register FCM token after login
    PushNotificationService().registerSavedToken();

    if (!context.mounted) return;

    if (data.approvalStatus == 'approved') {
      PageRouteUtils.pushAndRemoveUntil(context, const Dashboard());
    } else {
      PageRouteUtils.pushAndRemoveUntil(
        context,
        StatusPage(approvalStatus: data.approvalStatus ?? 'pending'),
      );
    }
  }
}
