class CoachingInfo {
  final String id;
  final String title;
  final String coachingType;
  final int maxPlayers;
  final int? arenaId;

  CoachingInfo({
    required this.id,
    required this.title,
    required this.coachingType,
    required this.maxPlayers,
    this.arenaId,
  });

  factory CoachingInfo.fromJson(Map<String, dynamic> json) => CoachingInfo(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        coachingType: json['coaching_type'] ?? 'group',
        maxPlayers: json['max_players'] ?? 0,
        arenaId: json['arena_id'],
      );
}

class SessionPlayer {
  final String playerId;
  final String? name;
  final String? phone;

  SessionPlayer({required this.playerId, this.name, this.phone});

  factory SessionPlayer.fromJson(Map<String, dynamic> json) => SessionPlayer(
        playerId: json['player_id'] ?? '',
        name: json['name'],
        phone: json['phone'],
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
    final todayDate = DateTime(now.year, now.month, now.day);
    final parts = sessionDate.split('-');
    if (parts.length < 3) return false;
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    return date.isBefore(todayDate);
  }
}
