import 'dart:async';
import 'package:flutter/material.dart';
import 'package:padel_coach/models/verify_otp_response.dart';
import '../core/base/base_view_model.dart';

class OtpViewModel extends BaseViewModel {
  String _otp = '';
  bool _isValidOtp = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  final TextEditingController otpController = TextEditingController();

  String get otp => _otp;
  bool get isValidOtp => _isValidOtp;
  int get secondsRemaining => _secondsRemaining;

  void onOtpChanged(String value) {
    _otp = value;
    _isValidOtp = _otp.length == 6;
    notifyListeners();
  }

  void setOtp(String value) {
    otpController.text = value;
    onOtpCompleted(value);
  }

  void onOtpCompleted(String value) {
    _otp = value;
    _isValidOtp = true;
    notifyListeners();
  }

  void startResendTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOtp(BuildContext context, String phone) async {
    setLoading(true);
    try {
      await apiService.sendOtp(context, phone);
      startResendTimer();
    } catch (_) {}
    setLoading(false);
  }

  Future<VerifyOtpResponse?> verifyOtp(BuildContext context, String phone) async {
    if (!_isValidOtp) return null;
    setLoading(true);
    try {
      final response = await apiService.verifyOtp(context, phone, _otp);
      setLoading(false);
      return response;
    } catch (e) {
      setLoading(false);
      debugPrint('verifyOtp error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }
}
