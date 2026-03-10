import 'package:flutter/material.dart';
import 'package:padel_coach/models/send_otp_response.dart';
import '../core/base/base_view_model.dart';

class LoginViewModel extends BaseViewModel {
  String _completeNumber = '';
  bool _isValidNumber = false;

  String get completeNumber => _completeNumber;
  bool get getIsValidNumber => _isValidNumber;

  void setValidNumber(bool isValid, String number) {
    _isValidNumber = isValid;
    _completeNumber = number;
    notifyListeners();
  }

  Future<SendOtpResponse?> sendOTP(BuildContext context) async {
    if (!_isValidNumber) return null;
    setLoading(true);
    try {
      final response = await apiService.sendOtp(context, _completeNumber);
      setLoading(false);
      return response;
    } catch (e) {
      setLoading(false);
      debugPrint('sendOTP error: $e');
      return null;
    }
  }
}
