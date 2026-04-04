import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../widgets/booking_qr_widget.dart';
import '../widgets/player_avatar_widget.dart';
import '../widgets/section_tile.dart';

class CoachBookingDetailPage extends StatefulWidget {
  final String playerName;
  final String playerPhone;
  final String? playerImageUrl;
  final String date;
  final String timeRange;
  final String? courtName;
  final String arenaName;
  final String arenaAddress;
  final String status;
  final String price;
  final String type;
  final List<String> playerImages;
  final String? privateBookingId; // If set, fetches full detail from API

  const CoachBookingDetailPage({
    super.key,
    required this.playerName,
    this.playerPhone = '',
    this.playerImageUrl,
    required this.date,
    required this.timeRange,
    this.courtName,
    required this.arenaName,
    this.arenaAddress = '',
    required this.status,
    this.price = '0',
    this.type = 'Private Coaching',
    this.playerImages = const [],
    this.privateBookingId,
  });

  @override
  State<CoachBookingDetailPage> createState() => _CoachBookingDetailPageState();
}

class _CoachBookingDetailPageState extends State<CoachBookingDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.privateBookingId != null) _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      _detail = await ApiService().getPrivateBookingDetail(context, widget.privateBookingId!);
    } catch (_) { /* use props as fallback */ }
    finally { if (mounted) setState(() => _loading = false); }
  }

  String _fmtDate(String raw) {
    try { return DateFormat('EEE, MMM d').format(DateTime.parse(raw).toLocal()); }
    catch (_) { return raw; }
  }

  String _fmtTime(String raw) {
    try {
      final parts = raw.split(':');
      final h = int.parse(parts[0]);
      final m = parts[1];
      final p = h >= 12 ? 'PM' : 'AM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:$m $p';
    } catch (_) { return raw; }
  }

  @override
  Widget build(BuildContext context) {
    // Use API detail if available, else use widget props
    final d = _detail;
    final playerName = d != null && (d['players'] as List?)?.isNotEmpty == true
        ? (d['players'] as List).first['name'] ?? widget.playerName
        : widget.playerName;
    final playerPhone = d != null && (d['players'] as List?)?.isNotEmpty == true
        ? (d['players'] as List).first['phone'] ?? widget.playerPhone
        : widget.playerPhone;
    final playerDocUrl = d != null && (d['players'] as List?)?.isNotEmpty == true
        ? (d['players'] as List).first['document_url']
        : widget.playerImageUrl;
    final date = d?['session_date'] ?? d?['booking_date'] ?? widget.date;
    final startTime = (d?['start_time'] ?? '').toString();
    final endTime = (d?['end_time'] ?? '').toString();
    final timeRange = startTime.isNotEmpty && endTime.isNotEmpty
        ? '${_fmtTime(startTime)} - ${_fmtTime(endTime)}'
        : widget.timeRange.split(' - ').map((t) => _fmtTime(t.trim())).join(' - ');
    final courtName = d?['court_name'] ?? widget.courtName;
    final arenaName = d?['arena_name'] ?? widget.arenaName;
    final arenaAddress = d?['display_address'] ?? widget.arenaAddress;
    final status = d?['booking_status'] ?? d?['status'] ?? widget.status;
    final price = d?['coaching_fee']?.toString() ?? d?['price']?.toString() ?? widget.price;
    final displayId = d?['display_id']?.toString() ?? '';
    final bookingId = d?['booking_id'] ?? '';
    final type = widget.type;
    final isPrivate = type != 'Group Coaching';

    final players = d != null ? List<Map<String, dynamic>>.from(d['players'] ?? []) : <Map<String, dynamic>>[];
    final playerImgs = players.map((p) => (p['document_url'] ?? '') as String).toList();
    if (playerImgs.isEmpty) playerImgs.addAll(widget.playerImages);

    final statusColor = _statusColor(status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1D3916),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context)),
                    const Expanded(child: Center(child: Text('Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          // Player / Session info — using exact SectionTile from app_player
                          SectionTile(
                            title: playerName,
                            description: playerPhone.isNotEmpty
                                ? '+91 $playerPhone'
                                : !isPrivate ? 'Group Coaching Session' : null,
                            trailingIcon: Icon(
                              isPrivate ? Icons.person : Icons.groups,
                              color: const Color(0xFF1D3916),
                            ),
                          ),

                          // Date
                          SectionTile(
                            title: 'Date',
                            description: '${_fmtDate(date)}  $timeRange',
                          ),

                          // Court
                          if (courtName != null && courtName.toString().isNotEmpty)
                            SectionTile(
                              title: 'Court',
                              description: courtName.toString(),
                            ),

                          // Arena + navigation
                          SectionTile(
                            title: arenaName,
                            description: arenaAddress,
                            trailingIcon: GestureDetector(
                              onTap: () async {
                                final query = Uri.encodeComponent('$arenaName $arenaAddress');
                                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              },
                              child: const Icon(Icons.navigation, color: Color(0xFF1D3916)),
                            ),
                          ),

                          // QR Code (only for private bookings with booking_id)
                          if (isPrivate && displayId.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: BookingQRCard(
                                bookingId: displayId,
                                qrData: '${bookingId}_${players.isNotEmpty ? players.first['player_id'] : ''}',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Players card — exact same widget as app_player
                          PlayersCard(
                            imageUrls: playerImgs,
                            playerTitle: 'Players',
                            hideEmptySlots: isPrivate,
                            courtNumber: status.toLowerCase() == 'confirmed' ? (isPrivate ? 'Private Coaching' : 'Confirmed')
                                : status.toLowerCase() == 'cancelled' ? 'Game Cancelled'
                                : status.toLowerCase() == 'completed' ? 'Completed'
                                : status.toLowerCase() == 'scheduled' ? 'Scheduled'
                                : status[0].toUpperCase() + status.substring(1),
                          ),
                          const SizedBox(height: 16),

                          // Total — show coaching fee only for coach
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2F0D7)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                SizedBox(height: 2),
                                Text('Tax (Inc)', style: TextStyle(fontSize: 12, color: Colors.black45)),
                              ]),
                              Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1D3916))),
                            ]),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                  ),
                ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF22C55E);
      case 'completed': return const Color(0xFF3B82F6);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return AppColors.primary;
    }
  }
}
