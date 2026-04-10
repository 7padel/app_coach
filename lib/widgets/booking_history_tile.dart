import 'package:flutter/material.dart';

import 'cached_circle_avatar.dart';

class BookingHistoryTile extends StatelessWidget {
  final String bookingId;
  final String matchType;
  final String venue;
  final String address;
  final String dateTime;
  final String statusLabel;
  final Color statusColor;
  final Color statusTextColor;
  final List<String> playerImages;
  final void Function(int index)? onInviteTap;
  final bool isPastOrder;

  const BookingHistoryTile({
    super.key,
    required this.bookingId,
    required this.matchType,
    required this.venue,
    required this.address,
    required this.dateTime,
    required this.statusLabel,
    required this.statusColor,
    required this.statusTextColor,
    required this.playerImages,
    this.onInviteTap,
    this.isPastOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    // Handle more than 4 players: show first 3 + count badge
    final hasExtra = playerImages.length > 4;
    final extraCount = hasExtra ? playerImages.length - 3 : 0;
    // If no players, show 4 empty circles; otherwise show actual players
    final fixedList = hasExtra
        ? playerImages.take(3).toList()
        : playerImages.isEmpty
            ? List<String>.generate(4, (_) => '')
            : playerImages.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCE3B8), width: 1.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📘 Left Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Visibility(
                      visible: bookingId.isNotEmpty,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE6CC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Booking ID: $bookingId',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D3916),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(matchType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Text(venue, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1D3916))),
                    const SizedBox(height: 4),
                    Text(address, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Text('Date', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D3916), fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(dateTime, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    //const Text('Booking Details', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D3916), fontSize: 15)),
                    //const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D3916))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusTextColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16)
                  ],
                ),
              ),
            ),

            // 🧍 Right side: vertical avatars
            Container(
                width: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D3916),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(fixedList.length, (index) {
                    final img = fixedList[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: CachedCircleAvatar(
                          imageUrl: img,
                          radius: 20,
                        ),
                      ),
                    );
                  }),
                    if (hasExtra)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Text('+$extraCount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D3916))),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

