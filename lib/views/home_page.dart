import '../core/theme/phase2_theme.dart';
import 'package:flutter/material.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../models/coaching_session_model.dart';
// private_booking_model import removed — using CoachBookingDetailPage
import '../viewmodels/home_view_model.dart';
import 'coach_booking_detail_page.dart';
import '../widgets/booking_history_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      model: HomeViewModel(),
      onModelReady: (vm) => vm.loadSessions(context),
      builder:
          (context, vm, _) => Phase2Surface(
            child: Scaffold(
              backgroundColor: Phase2Style.canvas,
              body: Column(
                children: [
                  const Phase2Heading(
                    title: 'Your schedule',
                    subtitle:
                        'Group sessions and private bookings, in one place.',
                    showBack: false,
                  ),

                  // Tab switcher
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _TabButton(
                            label: 'Group Coaching',
                            selected: vm.selectedTab == 0,
                            onTap: () => vm.setTab(0, context),
                          ),
                          _TabButton(
                            label: 'Private Booking',
                            selected: vm.selectedTab == 1,
                            onTap: () => vm.setTab(1, context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child:
                        vm.selectedTab == 0
                            ? _GroupCoachingTab(vm: vm)
                            : _PrivateBookingTab(vm: vm),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ─── Tab Button ──────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration:
                MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1D3916) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Group Coaching Tab ──────────────────────────────────────────────────────
class _GroupCoachingTab extends StatelessWidget {
  final HomeViewModel vm;
  const _GroupCoachingTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.sessionError != null && vm.sessions.isEmpty)
      return Phase2EmptyState(
        title: 'Unable to load sessions',
        message: vm.sessionError!,
        onRetry: () => vm.loadSessions(context, refresh: true),
      );
    if (vm.sessions.isEmpty)
      return _emptyState(
        'No Group Sessions',
        'Your coaching sessions will appear here.',
      );

    final today = vm.todaySessions;
    final upcoming = vm.upcomingSessions;

    if (today.isEmpty && upcoming.isEmpty) {
      return _emptyState(
        'No Upcoming Sessions',
        'Your upcoming coaching sessions will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.refresh(context),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (today.isNotEmpty) ...[
            _SectionHeader(title: "Today's Sessions", count: today.length),
            const SizedBox(height: 8),
            ...today.map((s) => _SessionCard(session: s, isToday: true)),
            const SizedBox(height: 16),
          ],
          if (upcoming.isNotEmpty) ...[
            _SectionHeader(title: 'Upcoming', count: upcoming.length),
            const SizedBox(height: 8),
            ...upcoming.map((s) => _SessionCard(session: s, isToday: false)),
          ],
          if (vm.hasMore)
            Center(
              child: TextButton(
                onPressed: () => vm.loadMore(context),
                child:
                    vm.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Load more'),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Private Booking Tab ─────────────────────────────────────────────────────
class _PrivateBookingTab extends StatelessWidget {
  final HomeViewModel vm;
  const _PrivateBookingTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.privateLoading && vm.privateBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.privateError != null && vm.privateBookings.isEmpty)
      return Phase2EmptyState(
        title: 'Unable to load bookings',
        message: vm.privateError!,
        onRetry: () => vm.loadPrivateBookings(context),
      );

    // Filter to upcoming only — check both date AND end time
    final now = DateTime.now();
    final upcoming =
        vm.privateBookings.where((b) {
          final dateStr = b['session_date'] ?? b['booking_date'] ?? '';
          final endTimeStr = (b['end_time'] ?? '23:59').toString();
          final d = DateTime.tryParse(dateStr);
          if (d == null) return false;
          // Combine date + end_time to check if booking has ended
          final endParts = endTimeStr.split(':');
          final endHour =
              int.tryParse(endParts.isNotEmpty ? endParts[0] : '23') ?? 23;
          final endMin =
              int.tryParse(endParts.length > 1 ? endParts[1] : '59') ?? 59;
          final endDateTime = DateTime(d.year, d.month, d.day, endHour, endMin);
          return endDateTime.isAfter(now);
        }).toList();

    if (upcoming.isEmpty)
      return _emptyState(
        'No Upcoming Private Bookings',
        'Your private coaching bookings will appear here.',
      );

    return RefreshIndicator(
      onRefresh: () => vm.refresh(context),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          final b = upcoming[index];
          return _PrivateBookingCard(booking: b);
        },
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────
Widget _emptyState(String title, String subtitle) =>
    Phase2EmptyState(title: title, message: subtitle);

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final CoachingSessionModel session;
  final bool isToday;
  const _SessionCard({required this.session, required this.isToday});

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'confirmed':
        return const Color(0xFF22C55E);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = session.status ?? 'scheduled';
    final statusLabel =
        status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1)
            : status;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CoachBookingDetailPage(
                    playerName: session.coaching?.title ?? 'Session',
                    date: session.sessionDate,
                    timeRange: '${session.startTime} - ${session.endTime}',
                    arenaName: session.arenaName ?? '',
                    arenaAddress: session.displayAddress ?? '',
                    status: status,
                    price:
                        session.coaching?.pricePerPerson?.toStringAsFixed(0) ??
                        '0',
                    type: 'Group Coaching',
                    playerImages:
                        session.registeredPlayers
                            .map((p) => p.documentUrl ?? '')
                            .toList(),
                  ),
            ),
          ),
      child: BookingHistoryTile(
        bookingId: '',
        matchType: 'Group Coaching',
        venue: session.arenaName ?? session.coaching?.title ?? 'Session',
        address: session.displayAddress ?? '',
        dateTime:
            '${DateHelper.prettyDate(session.sessionDate ?? '')} ${DateHelper.prettyTimeRange(session.startTime, session.endTime)}',
        statusLabel: statusLabel,
        statusColor: _statusColor(status),
        statusTextColor: Colors.white,
        playerImages:
            session.registeredPlayers.map((p) => p.documentUrl ?? '').toList(),
        isPastOrder: session.isPast,
      ),
    );
  }
}

class _PrivateBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _PrivateBookingCard({required this.booking});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] ?? 'Pending';
    final arenaName = booking['arena']?['name'] ?? booking['arena_name'] ?? '';
    final arenaAddress =
        booking['display_address'] ?? booking['arena']?['address'] ?? '';
    final date = booking['session_date'] ?? booking['booking_date'] ?? '';
    final startTime = (booking['start_time'] ?? '').toString();
    final endTime = (booking['end_time'] ?? '').toString();
    final displayId =
        booking['display_id']?.toString() ??
        booking['id']?.toString().substring(0, 8) ??
        '';
    final players = booking['players'] as List<dynamic>? ?? [];
    final playerImgs =
        players
            .map(
              (p) =>
                  (p['document_url'] ??
                          p['profile_picture_url'] ??
                          p['Document']?['document_url'] ??
                          '')
                      as String,
            )
            .toList();

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CoachBookingDetailPage(
                    playerName:
                        players.isNotEmpty
                            ? (players.first['name'] ?? 'Player')
                            : 'Player',
                    playerPhone:
                        players.isNotEmpty
                            ? (players.first['phone'] ?? '')
                            : '',
                    date: date,
                    timeRange:
                        '${startTime.length >= 5 ? startTime.substring(0, 5) : startTime} - ${endTime.length >= 5 ? endTime.substring(0, 5) : endTime}',
                    arenaName: arenaName,
                    arenaAddress: arenaAddress,
                    status: status,
                    price: booking['price']?.toString() ?? '0',
                    type: 'Private Coaching',
                    privateBookingId: booking['id']?.toString(),
                  ),
            ),
          ),
      child: BookingHistoryTile(
        bookingId: displayId,
        matchType: 'Private Match',
        venue: arenaName,
        address: arenaAddress,
        dateTime:
            '${DateHelper.prettyDate(date)} ${DateHelper.prettyTimeRange(startTime, endTime)}',
        statusLabel:
            status.isNotEmpty
                ? status[0].toUpperCase() + status.substring(1)
                : status,
        statusColor: _statusColor(status),
        statusTextColor: Colors.white,
        playerImages: playerImgs,
        isPastOrder: false,
      ),
    );
  }
}
