import 'package:flutter/material.dart';
import '../core/base/base_view_model.dart';
import '../core/utils/app_utils.dart';
import '../models/coach_time_off_model.dart';

class TimeOffViewModel extends BaseViewModel {
  List<CoachTimeOffModel> _timeOffs = [];
  List<CoachTimeOffModel> get timeOffs => _timeOffs;

  bool _submitting = false;
  bool get submitting => _submitting;

  Future<void> loadTimeOffs(BuildContext context) async {
    setLoading(true);
    try {
      final data = await apiService.getTimeOffs(context);
      final list = (data['time_offs'] as List<dynamic>? ?? [])
          .map((e) => CoachTimeOffModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _timeOffs = list;
    } catch (_) {
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createTimeOff(BuildContext context,
      {required String date,
      String? startTime,
      String? endTime,
      String? reason}) async {
    _submitting = true;
    notifyListeners();
    try {
      final payload = {
        'date': date,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };
      final result = await apiService.createTimeOff(context, payload);
      _timeOffs.insert(0, CoachTimeOffModel.fromJson(result));
      AppUtils.showToast('Time-off added');
      return true;
    } catch (_) {
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteTimeOff(BuildContext context, String id) async {
    try {
      await apiService.deleteTimeOff(context, id);
      _timeOffs.removeWhere((t) => t.id == id);
      notifyListeners();
      AppUtils.showToast('Time-off removed');
    } catch (_) {}
  }
}
