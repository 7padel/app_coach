class CoachingInfo {
  final String id;
  final String title;
  final String coachingType;
  final int maxPlayers;
  final int? arenaId;
  final double? pricePerPerson;

  CoachingInfo({
    required this.id,
    required this.title,
    required this.coachingType,
    required this.maxPlayers,
    this.arenaId,
    this.pricePerPerson,
  });

  factory CoachingInfo.fromJson(Map<String, dynamic> json) => CoachingInfo(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        coachingType: json['coaching_type'] ?? 'group',
        maxPlayers: json['max_players'] ?? 0,
        arenaId: json['arena_id'],
        pricePerPerson: double.tryParse(json['price_per_person']?.toString() ?? ''),
      );
}

class SessionPlayer {
  final String playerId;
  final String? name;
  final String? phone;
  final String? documentUrl;

  SessionPlayer({required this.playerId, this.name, this.phone, this.documentUrl});

  factory SessionPlayer.fromJson(Map<String, dynamic> json) => SessionPlayer(
        playerId: json['player_id'] ?? '',
        name: json['name'],
        phone: json['phone'],
        documentUrl: json['document_url'],
      );
}

class CoachingSessionModel {
  final String id;
  final String coachingId;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final String status;
  final int registeredCount;
  final String? arenaName;
  final String? displayAddress;
  final CoachingInfo? coaching;
  final List<SessionPlayer> registeredPlayers;

  CoachingSessionModel({
    required this.id,
    required this.coachingId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.registeredCount,
    this.arenaName,
    this.displayAddress,
    this.coaching,
    this.registeredPlayers = const [],
  });

  factory CoachingSessionModel.fromJson(Map<String, dynamic> json) =>
      CoachingSessionModel(
        id: json['id'] ?? '',
        coachingId: json['coaching_id'] ?? '',
        sessionDate: json['session_date'] ?? '',
        startTime: (json['start_time'] ?? '').toString().substring(0, 5),
        endTime: (json['end_time'] ?? '').toString().substring(0, 5),
        status: json['status'] ?? 'scheduled',
        registeredCount: json['registered_count'] ?? 0,
        arenaName: json['arena_name'],
        displayAddress: json['display_address'],
        coaching: json['coaching'] != null
            ? CoachingInfo.fromJson(json['coaching'])
            : null,
        registeredPlayers: (json['registered_players'] as List? ?? [])
            .map((p) => SessionPlayer.fromJson(p))
            .toList(),
      );

  bool get isToday {
    final today = DateTime.now();
    final parts = sessionDate.split('-');
    if (parts.length < 3) return false;
    return today.year == int.parse(parts[0]) &&
        today.month == int.parse(parts[1]) &&
        today.day == int.parse(parts[2]);
  }

  bool get isPast {
    final now = DateTime.now();
    final parts = sessionDate.split('-');
    if (parts.length < 3) return false;
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    // Check end time too — if session ended today, it's past
    final endParts = endTime.split(':');
    final endHour = int.tryParse(endParts.isNotEmpty ? endParts[0] : '23') ?? 23;
    final endMin = int.tryParse(endParts.length > 1 ? endParts[1] : '59') ?? 59;
    final endDateTime = DateTime(date.year, date.month, date.day, endHour, endMin);
    return endDateTime.isBefore(now);
  }
}
