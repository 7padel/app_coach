import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:padel_coach/views/register_view.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/page_route_utils.dart';
import '../viewmodels/login_view_model.dart';
import '../widgets/button.dart';
import 'otp_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginViewModel>(
      model: LoginViewModel(),
      builder: (context, model, _) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bottomPadding = constraints.maxHeight < 600 ? 16.0 : 24.0;
              final mainPadding = EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + bottomPadding,
              );

              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.bg_login,
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
                    child: SingleChildScrollView(
                      padding: mainPadding,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                AppStrings.enter_phone_number,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: constraints.maxHeight < 600 ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Coach Portal',
                                style: TextStyle(color: Colors.white60, fontSize: 16),
                              ),
                              const SizedBox(height: 20),

                              // Phone Input
                              IntlPhoneField(
                                flagsButtonPadding: const EdgeInsets.only(left: 12),
                                dropdownIconPosition: IconPosition.trailing,
                                dropdownIcon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                showCountryFlag: false,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: AppStrings.phone_number,
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                dropdownTextStyle: const TextStyle(color: Colors.white),
                                style: const TextStyle(color: Colors.white),
                                initialCountryCode: 'IN',
                                onChanged: (phone) {
                                  model.setValidNumber(phone.isValidNumber(), phone.number);
                                },
                              ),
                              const SizedBox(height: 20),

                              // Get Code Button
                              model.isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : SizedBox(
                                      width: double.infinity,
                                      child: Button(
                                        onPressed: model.getIsValidNumber
                                            ? () async {
                                                final response = await model.sendOTP(context);
                                                if (response != null && context.mounted) {
                                                  PageRouteUtils.pushWithSlide(
                                                    context,
                                                    OtpView(
                                                      phoneNo: model.completeNumber,
                                                      otp: response.data?.otp ?? '',
                                                    ),
                                                  );
                                                }
                                              }
                                            : null,
                                        text: AppStrings.get_code,
                                      ),
                                    ),
                              const SizedBox(height: 20),

                              // Register link
                              Center(
                                child: GestureDetector(
                                  onTap: () => PageRouteUtils.pushWithSlide(context, const RegisterView()),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: RichText(
                                      text: const TextSpan(
                                        text: "New coach? ",
                                        style: TextStyle(color: Colors.white60, fontSize: 15),
                                        children: [
                                          TextSpan(
                                            text: AppStrings.register_as_coach,
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
