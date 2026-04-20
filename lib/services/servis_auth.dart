// Simple auth state — tidak perlu package tambahan
// Ganti dengan session/token asli saat integrasi ke API Laravel

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  void login({required String name, required String email}) {
    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
  }
}