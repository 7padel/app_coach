import 'package:flutter/material.dart';
import 'package:padel_coach/models/register_response.dart';
import '../core/base/base_view_model.dart';

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

  String get phoneNumber => _phoneNumber;
  String get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  int get experienceYears => _experienceYears;
  String get specializationLevel => _specializationLevel;
  int get sportTypeId => _sportTypeId;

  void setPhone(String value) { _phoneNumber = value; notifyListeners(); }
  void setGender(String value) { _gender = value; notifyListeners(); }
  void setDateOfBirth(DateTime value) { _dateOfBirth = value; notifyListeners(); }
  void setExperienceYears(int value) { _experienceYears = value; notifyListeners(); }
  void setSpecializationLevel(String value) { _specializationLevel = value; notifyListeners(); }
  void setSportTypeId(int value) { _sportTypeId = value; notifyListeners(); }

  bool get isValid =>
      fullNameCtrl.text.trim().isNotEmpty &&
      emailCtrl.text.trim().isNotEmpty &&
      _phoneNumber.isNotEmpty;

  Future<RegisterResponse?> register(BuildContext context) async {
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
