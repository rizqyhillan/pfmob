import 'dart:io';

import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  Future<UserProfile?> loadProfile() async {
    final result = await runBusy(ApiService.getProfile);
    _profile = result;
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
}
