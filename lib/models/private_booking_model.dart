class BookingPlayer {
  final String playerId;
  final String? name;
  final String? phone;

  BookingPlayer({required this.playerId, this.name, this.phone});

  factory BookingPlayer.fromJson(Map<String, dynamic> json) => BookingPlayer(
        playerId: json['player_id'] ?? '',
        name: json['name'],
        phone: json['phone'],
      );
}

class PrivateBookingModel {
  final String id;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String status;
  final String paymentStatus;
  final double price;
  final String currencyCode;
  final String? arenaName;
  final List<BookingPlayer> players;

  PrivateBookingModel({
    required this.id,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    required this.paymentStatus,
    required this.price,
    required this.currencyCode,
    this.arenaName,
    required this.players,
  });

  factory PrivateBookingModel.fromJson(Map<String, dynamic> json) =>
      PrivateBookingModel(
        id: json['id'] ?? '',
        sessionDate: json['session_date'] ?? '',
        startTime: (json['start_time'] ?? '').toString().substring(0, 5),
        endTime: (json['end_time'] ?? '').toString().substring(0, 5),
        durationMinutes: json['duration_minutes'] ?? 0,
        status: json['status'] ?? 'pending',
        paymentStatus: json['payment_status'] ?? 'pending',
        price: double.tryParse(json['price'].toString()) ?? 0.0,
        currencyCode: json['currency_code'] ?? 'INR',
        arenaName: json['arena_name'],
        players: (json['players'] as List<dynamic>? ?? [])
            .map((p) => BookingPlayer.fromJson(p))
            .toList(),
      );
}
