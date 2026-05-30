import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void setError(Object? error) {
    _errorMessage = error?.toString().replaceFirst('Exception: ', '');
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<T?> runBusy<T>(Future<T> Function() action) async {
    setLoading(true);
    clearError();
    try {
      return await action();
    } catch (e) {
      setError(e);
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> runAction(Future<void> Function() action) async {
    setLoading(true);
    clearError();
    try {
      await action();
      return true;
    } catch (e) {
      setError(e);
      return false;
    } finally {
      setLoading(false);
    }
  }
}
