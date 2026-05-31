import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _notifyScheduled = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void notifySafely() {
    if (_isDisposed) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    final canNotifyNow = phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;

    if (canNotifyNow) {
      notifyListeners();
      return;
    }

    if (_notifyScheduled) return;
    _notifyScheduled = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifySafely();
  }

  void setError(Object? error) {
    _errorMessage = error?.toString().replaceFirst('Exception: ', '');
    notifySafely();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifySafely();
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
