class SendOtpResponse {
  final bool? status;
  final String? message;
  final Data? data;

  SendOtpResponse({this.status, this.message, this.data});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) => SendOtpResponse(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null ? null : Data.fromJson(json['data']),
      );
}

class Data {
  final String? phoneNumber;
  final String? otp;

  Data({this.phoneNumber, this.otp});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        phoneNumber: json['phone_number'],
        otp: json['otp'],
      );
}
