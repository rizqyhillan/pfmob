import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  static const Duration defaultCacheDuration = Duration(minutes: 3);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  bool isCacheValid(DateTime? lastLoadedAt, {Duration maxAge = defaultCacheDuration}) {
    if (lastLoadedAt == null) return false;
    return DateTime.now().difference(lastLoadedAt) < maxAge;
  }

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void setError(Object? error) {
    final nextMessage = error?.toString().replaceFirst('Exception: ', '');
    if (_errorMessage == nextMessage) return;
    _errorMessage = nextMessage;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<T?> runBusy<T>(Future<T> Function() action, {bool notifyLoading = true}) async {
    if (notifyLoading) setLoading(true);
    clearError();
    try {
      return await action();
    } catch (e) {
      setError(e);
      return null;
    } finally {
      if (notifyLoading) setLoading(false);
    }
  }

  Future<bool> runAction(Future<void> Function() action, {bool notifyLoading = true}) async {
    if (notifyLoading) setLoading(true);
    clearError();
    try {
      await action();
      return true;
    } catch (e) {
      setError(e);
      return false;
    } finally {
      if (notifyLoading) setLoading(false);
    }
  }
}
