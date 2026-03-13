import 'package:flutter/material.dart';
import 'package:padel_coach/models/register_response.dart';
import '../core/base/base_view_model.dart';
import '../core/utils/app_utils.dart';

class RegisterViewModel extends BaseViewModel {
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final bioCtrl = TextEditingController();

  String _phoneNumber = '';
  String _gender = 'male';
  DateTime? _dateOfBirth;
  int _experienceYears = 1;
  String _specializationLevel = 'beginner';
  int _sportTypeId = 1;
  String? _profilePictureId;

  String get phoneNumber => _phoneNumber;
  String get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  int get experienceYears => _experienceYears;
  String get specializationLevel => _specializationLevel;
  int get sportTypeId => _sportTypeId;
  String? get profilePictureId => _profilePictureId;

  void setPhone(String value) { _phoneNumber = value; notifyListeners(); }
  void setGender(String value) { _gender = value; notifyListeners(); }
  void setDateOfBirth(DateTime value) { _dateOfBirth = value; notifyListeners(); }
  void setExperienceYears(int value) { _experienceYears = value; notifyListeners(); }
  void setSpecializationLevel(String value) { _specializationLevel = value; notifyListeners(); }
  void setSportTypeId(int value) { _sportTypeId = value; notifyListeners(); }
  void setProfilePictureId(String? value) { _profilePictureId = value; notifyListeners(); }

  bool get isValid =>
      fullNameCtrl.text.trim().isNotEmpty &&
      emailCtrl.text.trim().isNotEmpty &&
      _phoneNumber.isNotEmpty;

  /// Returns null if all validations pass, otherwise returns the error message.
  String? validate() {
    final name = fullNameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = _phoneNumber;

    if (name.isEmpty) return 'Name is required';
    if (email.isEmpty) return 'Email is required';

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Invalid email format';

    if (phone.isEmpty) return 'Phone number is required';

    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Invalid phone number. Must be 10 digits and start with 6-9';
    }

    if (_dateOfBirth == null) return 'Date of birth is required';

    if (_dateOfBirth!.year < 1950) {
      return 'Date of birth cannot be earlier than 1950';
    }

    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month ||
        (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    if (age < 18) return 'Coach must be at least 18 years old';

    if (_experienceYears <= 0) return 'Experience is required';

    if (_specializationLevel.isEmpty) return 'Specialization level is required';

    return null;
  }

  Future<RegisterResponse?> register(BuildContext context) async {
    final error = validate();
    if (error != null) {
      AppUtils.showToast(error);
      return null;
    }

    setLoading(true);
    try {
      final payload = {
        'full_name': fullNameCtrl.text.trim(),
        'phone_number': _phoneNumber,
        'email': emailCtrl.text.trim(),
        'gender': _gender,
        'date_of_birth': _dateOfBirth?.toIso8601String().split('T')[0],
        'experience_years': _experienceYears,
        'specialization_level': _specializationLevel,
        'bio': bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
        'sport_type_id': _sportTypeId,
        if (_profilePictureId != null) 'profile_picture_id': _profilePictureId,
      };
      final response = await apiService.register(context, payload);
      setLoading(false);
      return response;
    } catch (e) {
      setLoading(false);
      debugPrint('register error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }
}
