class VerifyOtpResponse {
  final bool? status;
  final String? message;
  final VerifyOtpData? data;

  VerifyOtpResponse({this.status, this.message, this.data});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null ? null : VerifyOtpData.fromJson(json['data']),
      );
}

class VerifyOtpData {
  final String? token;
  final String? coachId;
  final String? fullName;
  final String? approvalStatus;
  final String? registrationStatus;
  final bool? isActive;

  VerifyOtpData({
    this.token,
    this.coachId,
    this.fullName,
    this.approvalStatus,
    this.registrationStatus,
    this.isActive,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) => VerifyOtpData(
        token: json['token'],
        coachId: json['coach_id'],
        fullName: json['full_name'],
        approvalStatus: json['approval_status'],
        registrationStatus: json['registration_status'],
        isActive: json['is_active'],
      );
}
