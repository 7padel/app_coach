import 'package:flutter/material.dart';
import '../core/base/base_view_model.dart';
import '../models/private_booking_model.dart';

class PrivateBookingsViewModel extends BaseViewModel {
  List<PrivateBookingModel> _bookings = [];
  List<PrivateBookingModel> get bookings => _bookings;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> loadBookings(BuildContext context, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _bookings = [];
    }
    if (isLoading) return;
    setLoading(true);
    try {
      final data = await apiService.getPrivateBookings(context, page: _currentPage);
      final list = (data['private_bookings'] as List<dynamic>? ?? [])
          .map((e) => PrivateBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _bookings = refresh ? list : [..._bookings, ...list];
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
    await loadBookings(context);
  }
}
