class RegisterResponse {
  final bool? status;
  final String? message;
  final RegisterData? data;

  RegisterResponse({this.status, this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null ? null : RegisterData.fromJson(json['data']),
      );
}

class RegisterData {
  final String? coachId;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? approvalStatus;

  RegisterData({
    this.coachId,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.approvalStatus,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) => RegisterData(
        coachId: json['coach_id'],
        fullName: json['full_name'],
        phoneNumber: json['phone_number'],
        email: json['email'],
        approvalStatus: json['approval_status'],
      );
}
