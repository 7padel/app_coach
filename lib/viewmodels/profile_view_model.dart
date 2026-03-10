import 'package:flutter/material.dart';
import '../core/base/base_view_model.dart';
import '../core/utils/shared_preferences_util.dart';
import '../models/coach_profile_model.dart';
import '../views/login_view.dart';

class ProfileViewModel extends BaseViewModel {
  CoachProfileModel? _profile;
  CoachProfileModel? get profile => _profile;

  Future<void> loadProfile(BuildContext context) async {
    setLoading(true);
    try {
      final data = await apiService.getMe(context);
      _profile = CoachProfileModel.fromJson(data);
    } catch (_) {
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    await SharedPreferencesUtil().clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }
}
