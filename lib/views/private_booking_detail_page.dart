import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../models/private_booking_model.dart';

class PrivateBookingDetailPage extends StatelessWidget {
  final PrivateBookingModel booking;
  const PrivateBookingDetailPage({super.key, required this.booking});

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String get _statusText {
    if (booking.status.isEmpty) return booking.status;
    return booking.status[0].toUpperCase() + booking.status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Private Booking',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(children: [
              _DetailRow(
                icon: Icons.sports_tennis,
                label: 'Type',
                value: 'Private Coaching',
              ),
              _DetailRow(
                icon: Icons.circle,
                label: 'Status',
                valueWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _statusColor),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _InfoCard(children: [
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateHelper.fullDate(booking.sessionDate),
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: DateHelper.prettyTimeRange(
                    booking.startTime, booking.endTime),
              ),
              _DetailRow(
                icon: Icons.timelapse,
                label: 'Duration',
                value: '${booking.durationMinutes} min',
              ),
            ]),
            const SizedBox(height: 12),
            _InfoCard(children: [
              if (booking.arenaName != null)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Arena',
                  value: booking.arenaName!,
                ),
              _DetailRow(
                icon: Icons.payment,
                label: 'Price',
                value:
                    '₹${booking.price.toStringAsFixed(0)}',
              ),
              _DetailRow(
                icon: Icons.receipt_outlined,
                label: 'Payment',
                value: booking.paymentStatus,
              ),
            ]),
            if (booking.players.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PlayersCard(players: booking.players),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(height: 1)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _PlayersCard extends StatelessWidget {
  final List<BookingPlayer> players;
  const _PlayersCard({required this.players});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: [
                Icon(Icons.people, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                const Text('Players',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${players.length}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: players.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (_, i) {
              final p = players[i];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        (p.name?.isNotEmpty == true)
                            ? p.name![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name ?? 'Player',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A))),
                          if (p.phone != null) ...[
                            const SizedBox(height: 4),
                            Text(p.phone!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black45)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? '-',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A)),
              ),
        ],
      ),
    );
  }
}
