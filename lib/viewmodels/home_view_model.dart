import 'package:flutter/material.dart';
import '../core/base/base_view_model.dart';
import '../models/coach_profile_model.dart';
import '../models/coaching_session_model.dart';

class HomeViewModel extends BaseViewModel {
  CoachProfileModel? profile;

  // Tab: 0 = Group Coaching, 1 = Private Booking
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  void setTab(int tab, BuildContext context) {
    _selectedTab = tab;
    notifyListeners();
    if (tab == 0 && _sessions.isEmpty) loadSessions(context);
    if (tab == 1 && _privateBookings.isEmpty) loadPrivateBookings(context);
  }

  // Group Coaching Sessions
  List<CoachingSessionModel> _sessions = [];
  List<CoachingSessionModel> get sessions => _sessions;

  List<CoachingSessionModel> get todaySessions =>
      _sessions.where((s) => s.isToday).toList();

  List<CoachingSessionModel> get upcomingSessions =>
      _sessions.where((s) => !s.isToday && !s.isPast).toList();

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  // Private Bookings
  List<Map<String, dynamic>> _privateBookings = [];
  List<Map<String, dynamic>> get privateBookings => _privateBookings;
  bool _privateLoading = false;
  bool get privateLoading => _privateLoading;

  Future<void> loadSessions(BuildContext context, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _sessions = [];
    }
    if (isLoading) return;
    setLoading(true);
    try {
      // Load profile name for header
      if (profile == null) {
        try {
          final profileData = await apiService.getMe(context);
          profile = CoachProfileModel.fromJson(profileData);
        } catch (_) { /* non-critical */ }
      }
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

  Future<void> loadPrivateBookings(BuildContext context) async {
    _privateLoading = true;
    notifyListeners();
    try {
      final data = await apiService.getPrivateBookings(context);
      _privateBookings = List<Map<String, dynamic>>.from(data['private_bookings'] ?? data['bookings'] ?? []);
    } catch (_) {
      // error shown by ApiService
    } finally {
      _privateLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(BuildContext context) async {
    if (_selectedTab == 0) {
      await loadSessions(context, refresh: true);
    } else {
      await loadPrivateBookings(context);
    }
  }
}
