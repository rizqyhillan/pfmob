import 'package:flutter/foundation.dart';

import '../services/servis_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _authService.isLoggedIn;
  String get userName => _authService.userName;
  String get userEmail => _authService.userEmail;
  String get userPhoto => _authService.userPhoto;
  String get token => _authService.token;

  Future<void> loadLoginData() async {
    _setLoading(true);

    try {
      await _authService.loadLoginData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final success = await _authService.login(
      email: email,
      password: password,
    );

    _errorMessage = success ? null : 'Email atau password salah.';
    _setLoading(false);
    return success;
  }

  Future<bool> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final success = await _authService.register(
      nama: nama,
      email: email,
      password: password,
    );

    _errorMessage = success
        ? null
        : 'Registrasi gagal. Periksa kembali data kamu.';

    _setLoading(false);
    return success;
  }

  Future<bool> sendOtp({
    required String email,
  }) async {
    _setLoading(true);

    final result = await _authService.sendOtp(
      email: email,
    );

    if (result['success'] == true) {
      _errorMessage = null;
    } else {
      _errorMessage = result['message']?.toString() ?? 'Gagal mengirim OTP.';
    }

    _setLoading(false);
    return result['success'] == true;
  }

  Future<bool> verifyOtpAndRegister({
    required String nama,
    required String email,
    required String password,
    required String otp,
  }) async {
    _setLoading(true);

    final result = await _authService.verifyOtpAndRegister(
      nama: nama,
      email: email,
      password: password,
      otp: otp,
    );

    if (result['success'] == true) {
      _errorMessage = null;
    } else {
      _errorMessage = result['message']?.toString() ?? 'Verifikasi gagal.';
    }

    _setLoading(false);
    return result['success'] == true;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _errorMessage = null;
    _setLoading(false);
  }

  Future<void> updateLocalProfile({
    required String name,
    required String email,
    String? photo,
  }) async {
    await _authService.updateLocalProfile(
      name: name,
      email: email,
      photo: photo,
    );

    notifyListeners();
  }

  Future<void> saveLoginDataFromResponse(Map<String, dynamic> data) async {
    await _authService.saveLoginDataFromResponse(data);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
