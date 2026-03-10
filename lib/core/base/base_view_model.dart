import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _disposed = false;

  final ApiService apiService = ApiService();

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    if (_disposed) return;
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
