import 'package:flutter/material.dart';
import '../core/base/base_view_model.dart';
import '../models/coaching_session_model.dart';

class HomeViewModel extends BaseViewModel {
  List<CoachingSessionModel> _sessions = [];
  List<CoachingSessionModel> get sessions => _sessions;

  List<CoachingSessionModel> get todaySessions =>
      _sessions.where((s) => s.isToday).toList();

  List<CoachingSessionModel> get upcomingSessions =>
      _sessions.where((s) => !s.isToday && !s.isPast).toList();

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> loadSessions(BuildContext context, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _sessions = [];
    }
    if (isLoading) return;
    setLoading(true);
    try {
      final data = await apiService.getSessions(context, page: _currentPage);
      final list = (data['sessions'] as List<dynamic>? ?? [])
          .map((e) => CoachingSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _sessions = refresh ? list : [..._sessions, ...list];
      _totalPages = data['total_pages'] ?? 1;
    } catch (_) {
      // error shown by ApiService
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadMore(BuildContext context) async {
    if (!hasMore || isLoading) return;
    _currentPage++;
    await loadSessions(context);
  }
}
