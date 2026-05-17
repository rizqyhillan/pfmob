import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String baseUrl = ApiConfig.baseUrl;

  final storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhoto = '';
  String _token = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhoto => _userPhoto;
  String get token => _token;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _token = data['token'] ?? '';
        _userName = data['user']['nama'] ?? '';
        _userEmail = data['user']['email'] ?? '';
        _userPhoto = data['user']['foto'] ?? '';
        _isLoggedIn = true;

        ApiService.setToken(_token);

        await storage.write(key: 'token', value: _token);
        await storage.write(key: 'name', value: _userName);
        await storage.write(key: 'email', value: _userEmail);
        await storage.write(key: 'photo', value: _userPhoto);

        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> loadLoginData() async {
    final savedToken = await storage.read(key: 'token');
    final savedName = await storage.read(key: 'name');
    final savedEmail = await storage.read(key: 'email');
    _userPhoto = await storage.read(key: 'photo') ?? '';

    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _userName = savedName ?? '';
      _userEmail = savedEmail ?? '';
      _isLoggedIn = true;

      ApiService.setToken(_token);
    }
  }

  Future<void> logout() async {
    try {
      if (_token.isNotEmpty) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (_) {}

    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _token = '';

    ApiService.clearToken();

    await storage.deleteAll();
    await storage.delete(key: 'photo');
    _userPhoto = '';
  }

  Future<bool> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        _token = data['token'] ?? '';
        _userName = data['user']['nama'] ?? '';
        _userEmail = data['user']['email'] ?? '';
        _isLoggedIn = true;

        ApiService.setToken(_token);

        await storage.write(key: 'token', value: _token);
        await storage.write(key: 'name', value: _userName);
        await storage.write(key: 'email', value: _userEmail);

        return true;
      }

      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> updateLocalProfile({
    required String name,
    required String email,
    String? photo,
  }) async {
    _userName = name;
    _userEmail = email;

    if (photo != null) {
      _userPhoto = photo;
    }

    await storage.write(key: 'name', value: _userName);
    await storage.write(key: 'email', value: _userEmail);
    await storage.write(key: 'photo', value: _userPhoto);
  }

  Future<void> saveLoginDataFromResponse(Map<String, dynamic> data) async {
    _token = data['token'] ?? '';
    _userName = data['user']?['nama'] ?? '';
    _userEmail = data['user']?['email'] ?? '';
    _userPhoto = data['user']?['foto'] ?? '';
    _isLoggedIn = _token.isNotEmpty;

    if (_token.isNotEmpty) {
      ApiService.setToken(_token);

      await storage.write(key: 'token', value: _token);
      await storage.write(key: 'name', value: _userName);
      await storage.write(key: 'email', value: _userEmail);
      await storage.write(key: 'photo', value: _userPhoto);
    }
  }
}