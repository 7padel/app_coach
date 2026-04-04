import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dotted_border/dotted_border.dart';

class BookingQRCard extends StatelessWidget {
  final String bookingId;
  final String qrData;

  const BookingQRCard({
    super.key,
    required this.bookingId,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(16),
      dashPattern: const [6, 3],
      color: Colors.grey.shade300,
      strokeWidth: 1.5,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Booking ID: $bookingId',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3916),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              gapless: false,
            ),
          ],
        ),
      ),
    );
  }
}
