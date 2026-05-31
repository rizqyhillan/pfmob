import 'dart:io';

import '../models/models.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class PetViewModel extends BaseViewModel {
  List<Pet> _pets = const [];
  DateTime? _petsLoadedAt;

  List<Pet> get pets => _pets;

  Future<List<Pet>> loadPets({bool forceRefresh = false}) async {
    if (!forceRefresh && _pets.isNotEmpty && isCacheValid(_petsLoadedAt)) return _pets;

    final result = await runBusy(ApiService.getMyPets);
    _pets = result ?? const [];
    _petsLoadedAt = DateTime.now();
    notifyListeners();
    return _pets;
  }

  Future<bool> addPet({
    required String namaHewan,
    required String jenis,
    String? jenisKelamin,
    String? tanggalLahir,
    String? ras,
    String? umur,
    String? berat,
    String? catatan,
    File? fotoFile,
  }) async {
    final success = await runAction(() => ApiService.addPet(
          namaHewan: namaHewan,
          jenis: jenis,
          jenisKelamin: jenisKelamin,
          tanggalLahir: tanggalLahir,
          ras: ras,
          umur: umur,
          berat: berat,
          catatan: catatan,
          fotoFile: fotoFile,
        ));
    if (success) await loadPets(forceRefresh: true);
    return success;
  }

  Future<bool> updatePet({
    required int id,
    required String namaHewan,
    required String jenis,
    String? jenisKelamin,
    String? tanggalLahir,
    String? ras,
    String? umur,
    String? berat,
    String? catatan,
    File? fotoFile,
  }) async {
    final success = await runAction(() => ApiService.updatePet(
          id: id,
          namaHewan: namaHewan,
          jenis: jenis,
          jenisKelamin: jenisKelamin,
          tanggalLahir: tanggalLahir,
          ras: ras,
          umur: umur,
          berat: berat,
          catatan: catatan,
          fotoFile: fotoFile,
        ));
    if (success) await loadPets(forceRefresh: true);
    return success;
  }

  Future<bool> deletePet(int id) async {
    final success = await runAction(() => ApiService.deletePet(id));
    if (success) await loadPets(forceRefresh: true);
    return success;
  }

  void clearCache() {
    _petsLoadedAt = null;
  }
}
