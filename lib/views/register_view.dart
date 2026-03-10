import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/app_utils.dart';
import '../core/utils/page_route_utils.dart';
import '../viewmodels/register_view_model.dart';
import '../widgets/button.dart';
import 'status_page.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<RegisterViewModel>(
      model: RegisterViewModel(),
      builder: (context, model, _) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text('Register as Coach'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Full Name *'),
                _field(model.fullNameCtrl, 'Enter your full name'),
                _label('Phone Number *'),
                IntlPhoneField(
                  flagsButtonPadding: const EdgeInsets.only(left: 12),
                  dropdownIconPosition: IconPosition.trailing,
                  showCountryFlag: false,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: AppStrings.phone_number,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    if (phone.isValidNumber()) model.setPhone(phone.number);
                  },
                ),
                _label('Email *'),
                _field(model.emailCtrl, 'Enter your email', type: TextInputType.emailAddress),
                _label('Gender *'),
                _dropdown<String>(
                  value: model.gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (v) => model.setGender(v!),
                ),
                _label('Date of Birth'),
                _datePickerRow(context, model),
                _label('Years of Experience *'),
                _numberField(
                  value: model.experienceYears,
                  onDecrement: () => model.experienceYears > 0
                      ? model.setExperienceYears(model.experienceYears - 1)
                      : null,
                  onIncrement: () => model.setExperienceYears(model.experienceYears + 1),
                ),
                _label('Specialization Level *'),
                _dropdown<String>(
                  value: model.specializationLevel,
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (v) => model.setSpecializationLevel(v!),
                ),
                _label('Bio (optional)'),
                TextField(
                  controller: model.bioCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tell us about yourself...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                model.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary))
                    : Button(
                        color: AppColors.primary,
                        onPressed: model.isValid
                            ? () async {
                                final response = await model.register(context);
                                if (response?.status == true && context.mounted) {
                                  PageRouteUtils.pushAndRemoveUntil(
                                    context,
                                    const StatusPage(approvalStatus: 'pending'),
                                  );
                                } else if (response?.status == false) {
                                  AppUtils.showToast(
                                      response?.message ?? 'Registration failed');
                                }
                              }
                            : null,
                        text: AppStrings.register,
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textDark)),
      );

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _datePickerRow(BuildContext context, RegisterViewModel model) => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(1990),
            firstDate: DateTime(1950),
            lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
          );
          if (picked != null) model.setDateOfBirth(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model.dateOfBirth != null
                    ? '${model.dateOfBirth!.day}/${model.dateOfBirth!.month}/${model.dateOfBirth!.year}'
                    : 'Select date',
                style: TextStyle(
                    color: model.dateOfBirth != null ? AppColors.textDark : Colors.black38),
              ),
              const Icon(Icons.calendar_today, size: 20, color: AppColors.textGrey),
            ],
          ),
        ),
      );

  Widget _numberField({
    required int value,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) =>
      Row(
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
          ),
          Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      );
}
