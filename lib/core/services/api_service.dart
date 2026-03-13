import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:padel_coach/models/register_response.dart';
import 'package:padel_coach/models/send_otp_response.dart';
import 'package:padel_coach/models/verify_otp_response.dart';
import '../constants/app_config.dart';
import '../constants/app_logger.dart';
import '../utils/app_utils.dart';
import '../utils/shared_preferences_util.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.headers = {'Content-Type': 'application/json'};
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<void> addToken() async {
    final token = await SharedPreferencesUtil().getString('token');
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<T> _post<T>(String endpoint, Map<String, dynamic> data,
      T Function(Map<String, dynamic>) fromJson, BuildContext? context,
      {bool auth = false}) async {
    if (auth) await addToken();
    try {
      AppLogger.print('POST', '${AppConfig.baseUrl}$endpoint');
      final response = await _dio.post(endpoint,
          data: data,
          options: Options(validateStatus: (s) => s != null && s < 500));
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 403) {
        await SharedPreferencesUtil().clear();
        AppUtils.showToast('Session expired. Please log in again.');
        throw Exception('Unauthorized');
      } else {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.print('POST error', '$e');
      rethrow;
    }
  }

  Future<T> _get<T>(String endpoint, T Function(Map<String, dynamic>) fromJson,
      BuildContext? context,
      {Map<String, dynamic>? queryParams, bool auth = true}) async {
    if (auth) await addToken();
    try {
      AppLogger.print('GET', '${AppConfig.baseUrl}$endpoint');
      final response = await _dio.get(endpoint,
          queryParameters: queryParams,
          options: Options(validateStatus: (s) => s != null && s < 500));
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 403) {
        await SharedPreferencesUtil().clear();
        AppUtils.showToast('Session expired. Please log in again.');
        throw Exception('Unauthorized');
      } else {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.print('GET error', '$e');
      rethrow;
    }
  }

  Future<T> _put<T>(String endpoint, Map<String, dynamic> data,
      T Function(Map<String, dynamic>) fromJson, BuildContext? context) async {
    await addToken();
    try {
      AppLogger.print('PUT', '${AppConfig.baseUrl}$endpoint');
      final response = await _dio.put(endpoint,
          data: data,
          options: Options(validateStatus: (s) => s != null && s < 500));
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 403) {
        await SharedPreferencesUtil().clear();
        throw Exception('Unauthorized');
      } else {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.print('PUT error', '$e');
      rethrow;
    }
  }

  Future<T> _delete<T>(String endpoint,
      T Function(Map<String, dynamic>) fromJson, BuildContext? context) async {
    await addToken();
    try {
      final response = await _dio.delete(endpoint,
          options: Options(validateStatus: (s) => s != null && s < 500));
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      AppLogger.print('DELETE error', '$e');
      rethrow;
    }
  }

  // ─── Documents ────────────────────────────────────────────────────────────

  /// Uploads a file to /documents and returns the document_id.
  Future<String> uploadDocument(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'documents': await MultipartFile.fromFile(filePath),
      });
      AppLogger.print('POST', '${AppConfig.baseUrl}documents');
      final response = await _dio.post('documents',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            validateStatus: (s) => s != null && s < 500,
          ));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final doc = (response.data['data'] as List).first;
        return doc['document_id'] as String;
      }
      throw Exception(response.data['message'] ?? 'Upload failed');
    } catch (e) {
      AppLogger.print('Upload error', '$e');
      rethrow;
    }
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<RegisterResponse> register(BuildContext context, Map<String, dynamic> payload) {
    return _post('coaches/register', payload, RegisterResponse.fromJson, context);
  }

  Future<SendOtpResponse> sendOtp(BuildContext context, String phone) {
    return _post('coaches/send-otp', {'phone_number': phone},
        SendOtpResponse.fromJson, context);
  }

  Future<VerifyOtpResponse> verifyOtp(BuildContext context, String phone, String otp) {
    return _post('coaches/verify-otp', {'phone_number': phone, 'otp': otp},
        VerifyOtpResponse.fromJson, context);
  }

  // ─── Sessions ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getSessions(BuildContext? context,
      {String? date, String? status, int page = 1}) {
    return _get(
      'coaches/me/sessions',
      (json) => json['data'] as Map<String, dynamic>,
      context,
      queryParams: {
        'page': page,
        'limit': 20,
        if (date != null) 'date': date,
        if (status != null) 'status': status,
      },
    );
  }

  // ─── Private Bookings ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPrivateBookings(BuildContext? context,
      {String? status, int page = 1}) {
    return _get(
      'coaches/me/private-bookings',
      (json) => json['data'] as Map<String, dynamic>,
      context,
      queryParams: {
        'page': page,
        'limit': 20,
        if (status != null) 'status': status,
      },
    );
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMe(BuildContext? context) {
    return _get('coaches/me', (json) => json['data'] as Map<String, dynamic>,
        context);
  }

  Future<Map<String, dynamic>> updateMe(
      BuildContext? context, Map<String, dynamic> payload) {
    return _put('coaches/me', payload,
        (json) => json['data'] as Map<String, dynamic>, context);
  }

  // ─── Time-offs ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTimeOffs(BuildContext? context) {
    return _get(
        'coaches/me/time-offs',
        (json) => json['data'] as Map<String, dynamic>,
        context);
  }

  Future<Map<String, dynamic>> createTimeOff(
      BuildContext? context, Map<String, dynamic> payload) {
    return _post('coaches/me/time-offs', payload,
        (json) => json['data'] as Map<String, dynamic>, context, auth: true);
  }

  Future<Map<String, dynamic>> deleteTimeOff(
      BuildContext? context, String id) {
    return _delete('coaches/me/time-offs/$id',
        (json) => json, context);
  }
}
