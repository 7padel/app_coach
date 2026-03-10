import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:padel_coach/views/register_view.dart';
import '../core/base/base_view.dart';
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
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.sports_tennis, size: 60, color: AppColors.secondary),
                  const SizedBox(height: 40),
                  const Text(
                    AppStrings.enter_phone_number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Coach Portal',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  IntlPhoneField(
                    flagsButtonPadding: const EdgeInsets.only(left: 12),
                    dropdownIconPosition: IconPosition.trailing,
                    dropdownIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    showCountryFlag: false,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: AppStrings.phone_number,
                      hintStyle: const TextStyle(color: Colors.white60),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownTextStyle: const TextStyle(color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      model.setValidNumber(phone.isValidNumber(), phone.number);
                    },
                  ),
                  const SizedBox(height: 24),
                  model.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Button(
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
                  const Spacer(),
                  // Register link
                  Center(
                    child: GestureDetector(
                      onTap: () => PageRouteUtils.pushWithSlide(context, const RegisterView()),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
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
    );
  }
}
