import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../models/private_booking_model.dart';

class PrivateBookingDetailPage extends StatelessWidget {
  final PrivateBookingModel booking;
  const PrivateBookingDetailPage({super.key, required this.booking});

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF22C55E);
      case 'completed': return const Color(0xFF3B82F6);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return const Color(0xFFF59E0B);
    }
  }

  String get _statusText {
    if (booking.status.isEmpty) return booking.status;
    return booking.status[0].toUpperCase() + booking.status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
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
                    const Expanded(child: Center(child: Text('Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Details header
                  const Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1D3916))),
                  const SizedBox(height: 16),

                  // Player name + phone
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.players.isNotEmpty ? (booking.players.first.name ?? 'Player') : 'Player', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(booking.players.isNotEmpty ? (booking.players.first.phone ?? '') : '', style: const TextStyle(fontSize: 13, color: Colors.black45)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary,
                        child: Icon(Icons.person, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFE8E8E8)),

                  // Date + Time
                  const Text('Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${DateHelper.prettyDate(booking.sessionDate)} ${DateHelper.prettyTimeRange(booking.startTime, booking.endTime)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const Divider(height: 32, color: Color(0xFFE8E8E8)),

                  // Arena + Court
                  const Text('Arena', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Duration: ${booking.durationMinutes} min', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const Divider(height: 32, color: Color(0xFFE8E8E8)),

                  // Arena name + address
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.arenaName ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            const Text('', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                        child: Icon(Icons.navigation, size: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFE8E8E8)),

                  // Status
                  Row(
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _statusColor)),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFE8E8E8)),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text('Tax (Inc)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                      Text('₹${booking.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),

                  // Players section
                  if (booking.players.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.people, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Players', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                          child: Text('${booking.players.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...booking.players.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, size: 16, color: Colors.black45)),
                          const SizedBox(width: 10),
                          Text(p.name ?? 'Player', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(p.phone ?? '', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
