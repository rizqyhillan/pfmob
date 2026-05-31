import 'dart:io';

import '../models/models.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  UserProfile? _profile;
  DateTime? _profileLoadedAt;

  UserProfile? get profile => _profile;

  Future<UserProfile?> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _profile != null && isCacheValid(_profileLoadedAt)) return _profile;

    final result = await runBusy(ApiService.getProfile);
    _profile = result;
    _profileLoadedAt = DateTime.now();
    notifyListeners();
    return result;
  }

  Future<UserProfile?> updateProfile({
    required String nama,
    required String email,
    String? noHp,
    String? alamat,
    File? fotoFile,
  }) async {
    final result = await runBusy(() => ApiService.updateProfile(
          nama: nama,
          email: email,
          noHp: noHp,
          alamat: alamat,
          fotoFile: fotoFile,
        ));
    _profile = result;
    _profileLoadedAt = DateTime.now();
    notifyListeners();
    return result;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return runAction(() => ApiService.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ));
  }

  void clearCache() {
    _profileLoadedAt = null;
  }
}
