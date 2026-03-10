class CoachTimeOffModel {
  final String id;
  final String date;
  final String? startTime;
  final String? endTime;
  final String? reason;
  final String status;

  CoachTimeOffModel({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.reason,
    required this.status,
  });

  factory CoachTimeOffModel.fromJson(Map<String, dynamic> json) =>
      CoachTimeOffModel(
        id: json['id'] ?? '',
        date: json['date'] ?? '',
        startTime: json['start_time']?.toString().substring(0, 5),
        endTime: json['end_time']?.toString().substring(0, 5),
        reason: json['reason'],
        status: json['status'] ?? 'blocked',
      );
}
