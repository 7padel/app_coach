import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/utils/date_utils.dart';
import '../models/coaching_session_model.dart';
import '../widgets/booking_history_tile.dart';
import 'coach_booking_detail_page.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = Past
  bool _loading = true;

  List<CoachingSessionModel> _sessions = [];
  List<Map<String, dynamic>> _privateBookings = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final sessionsData = await ApiService().getSessions(context, page: 1);
      final privateData = await ApiService().getPrivateBookings(context);
      _sessions = (sessionsData['sessions'] as List<dynamic>? ?? [])
          .map((e) => CoachingSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _privateBookings = List<Map<String, dynamic>>.from(privateData['private_bookings'] ?? privateData['bookings'] ?? []);
    } catch (_) { /* silently fail */ }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF22C55E);
      case 'completed': return const Color(0xFF3B82F6);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return AppColors.primary;
    }
  }

  // Split items into upcoming/past
  List<Map<String, dynamic>> _filterPrivate(bool upcoming) {
    final now = DateTime.now();
    final filtered = _privateBookings.where((b) {
      final dateStr = b['session_date'] ?? b['booking_date'] ?? '';
      final endTimeStr = (b['end_time'] ?? '23:59').toString();
      final d = DateTime.tryParse(dateStr);
      if (d == null) return false;
      final endParts = endTimeStr.split(':');
      final endHour = int.tryParse(endParts.isNotEmpty ? endParts[0] : '23') ?? 23;
      final endMin = int.tryParse(endParts.length > 1 ? endParts[1] : '59') ?? 59;
      final endDateTime = DateTime(d.year, d.month, d.day, endHour, endMin);
      return upcoming ? endDateTime.isAfter(now) : !endDateTime.isAfter(now);
    }).toList();
    // Sort: nearest first for upcoming, most recent first for past
    filtered.sort((a, b) {
      final da = DateTime.tryParse(a['session_date'] ?? a['booking_date'] ?? '') ?? DateTime(2000);
      final db = DateTime.tryParse(b['session_date'] ?? b['booking_date'] ?? '') ?? DateTime(2000);
      return upcoming ? da.compareTo(db) : db.compareTo(da);
    });
    return filtered;
  }

  List<CoachingSessionModel> _filterSessions(bool upcoming) {
    final filtered = _sessions.where((s) => upcoming ? !s.isPast : s.isPast).toList();
    filtered.sort((a, b) {
      final da = DateTime.tryParse(a.sessionDate) ?? DateTime(2000);
      final db = DateTime.tryParse(b.sessionDate) ?? DateTime(2000);
      return upcoming ? da.compareTo(db) : db.compareTo(da);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1D3916),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    const Expanded(child: Center(child: Text('Booking History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Upcoming / Past tab switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFDCEAC8), borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.all(4),
              child: Row(children: [
                _TabBtn(label: 'Upcoming', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                _TabBtn(label: 'Past', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(onRefresh: _loadAll, child: _buildList()),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final isUpcoming = _selectedTab == 0;
    final privateBks = _filterPrivate(isUpcoming);
    final groupSessions = _filterSessions(isUpcoming);

    if (privateBks.isEmpty && groupSessions.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(isUpcoming ? 'No Upcoming Bookings' : 'No Past Bookings', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Your booking history will appear here.', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        // Private bookings section
        if (privateBks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Private Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1D3916))),
          ),
          ...privateBks.map((b) => _buildPrivateCard(b)),
          const SizedBox(height: 16),
        ],

        // Group coaching section
        if (groupSessions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Group Coaching', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1D3916))),
          ),
          ...groupSessions.map((s) => _buildSessionCard(s)),
        ],
      ],
    );
  }

  Widget _buildPrivateCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'Pending';
    final arenaName = booking['arena']?['name'] ?? booking['arena_name'] ?? '';
    final arenaAddress = booking['display_address'] ?? booking['arena']?['address'] ?? '';
    final date = booking['session_date'] ?? booking['booking_date'] ?? '';
    final startTime = (booking['start_time'] ?? '').toString();
    final endTime = (booking['end_time'] ?? '').toString();
    final displayId = booking['display_id']?.toString() ?? booking['id']?.toString().substring(0, 8) ?? '';
    final players = booking['players'] as List<dynamic>? ?? [];
    final playerImgs = players.map((p) => (p['document_url'] ?? p['Document']?['document_url'] ?? '') as String).toList();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoachBookingDetailPage(
        playerName: players.isNotEmpty ? (players.first['name'] ?? 'Player') : 'Player',
        playerPhone: players.isNotEmpty ? (players.first['phone'] ?? '') : '',
        date: date,
        timeRange: '${startTime.length >= 5 ? startTime.substring(0, 5) : startTime} - ${endTime.length >= 5 ? endTime.substring(0, 5) : endTime}',
        arenaName: arenaName,
        arenaAddress: arenaAddress,
        status: status,
        price: booking['price']?.toString() ?? '0',
        playerImages: playerImgs,
        privateBookingId: booking['id']?.toString(),
      ))),
      child: BookingHistoryTile(
        bookingId: displayId,
        matchType: 'Private Match',
        venue: arenaName,
        address: arenaAddress,
        dateTime: '${DateHelper.prettyDate(date)} ${DateHelper.prettyTimeRange(startTime, endTime)}',
        statusLabel: status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : status,
        statusColor: _statusColor(status),
        statusTextColor: Colors.white,
        playerImages: playerImgs,
        isPastOrder: _selectedTab == 1,
      ),
    );
  }

  Widget _buildSessionCard(CoachingSessionModel session) {
    final status = session.status;
    final statusLabel = status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : status;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoachBookingDetailPage(
        playerName: session.coaching?.title ?? 'Session',
        date: session.sessionDate,
        timeRange: '${session.startTime} - ${session.endTime}',
        arenaName: session.arenaName ?? session.coaching?.title ?? '',
        arenaAddress: session.displayAddress ?? '',
        status: status,
        price: session.coaching?.pricePerPerson?.toStringAsFixed(0) ?? '0',
        type: 'Group Coaching',
        playerImages: session.registeredPlayers.map((p) => p.documentUrl ?? '').toList(),
      ))),
      child: BookingHistoryTile(
        bookingId: '',
        matchType: 'Group Coaching',
        venue: session.arenaName ?? session.coaching?.title ?? 'Session',
        address: session.displayAddress ?? '',
        dateTime: '${DateHelper.prettyDate(session.sessionDate)} ${DateHelper.prettyTimeRange(session.startTime, session.endTime)}',
        statusLabel: statusLabel,
        statusColor: _statusColor(status),
        statusTextColor: Colors.white,
        playerImages: session.registeredPlayers.map((p) => p.documentUrl ?? '').toList(),
        isPastOrder: _selectedTab == 1,
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: selected ? const Color(0xFF1D3916) : Colors.transparent, borderRadius: BorderRadius.circular(40)),
          child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black))),
        ),
      ),
    );
  }
}
