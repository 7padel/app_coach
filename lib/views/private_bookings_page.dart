import 'package:flutter/material.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../models/private_booking_model.dart';
import '../viewmodels/private_bookings_view_model.dart';
import 'private_booking_detail_page.dart';

class PrivateBookingsPage extends StatelessWidget {
  const PrivateBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<PrivateBookingsViewModel>(
      model: PrivateBookingsViewModel(),
      onModelReady: (vm) => vm.loadBookings(context),
      builder: (context, vm, _) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Private Bookings',
              style: TextStyle(fontWeight: FontWeight.w600)),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => vm.loadBookings(context, refresh: true),
            ),
          ],
        ),
        body: vm.isLoading && vm.bookings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => vm.loadBookings(context, refresh: true),
                child: vm.bookings.isEmpty
                    ? _EmptyState()
                    : _BookingList(vm: vm),
              ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final PrivateBookingsViewModel vm;
  const _BookingList({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.bookings.length + (vm.hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == vm.bookings.length) {
          return Center(
            child: TextButton(
              onPressed: () => vm.loadMore(context),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load more'),
            ),
          );
        }
        return _BookingCard(booking: vm.bookings[i]);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final PrivateBookingModel booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerName = booking.players.isNotEmpty
        ? booking.players.first.name ?? 'Player'
        : 'Player';
    final extraPlayers = booking.players.length > 1
        ? ' +${booking.players.length - 1}'
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PrivateBookingDetailPage(booking: booking)),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$playerName$extraPlayers',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A)),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 13, color: Colors.black45),
                const SizedBox(width: 4),
                Text(DateHelper.prettyDate(booking.sessionDate),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 13, color: Colors.black45),
                const SizedBox(width: 4),
                Text(DateHelper.prettyTimeRange(booking.startTime, booking.endTime),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            if (booking.arenaName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 13, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(booking.arenaName!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${booking.durationMinutes} min',
                    style: const TextStyle(fontSize: 12, color: Colors.black45)),
                Text(
                  '${booking.currencyCode} ${booking.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Icon(Icons.person_pin_outlined, size: 64, color: Colors.black26),
        const SizedBox(height: 16),
        const Center(
          child: Text('No private bookings yet',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
        ),
      ],
    );
  }
}
