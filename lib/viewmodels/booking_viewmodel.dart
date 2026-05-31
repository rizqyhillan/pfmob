import '../models/models.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class BookingViewModel extends BaseViewModel {
  List<Doctor> _doctors = const [];
  List<DoctorServiceItem> _doctorServices = const [];
  Map<String, dynamic>? _doctorAvailability;
  List<PackageType> _groomingPackages = const [];
  Map<String, dynamic>? _groomingAvailability;
  List<BoardingRoom> _boardingRooms = const [];
  List<Pet> _pets = const [];

  DateTime? _doctorsLoadedAt;
  DateTime? _doctorDetailLoadedAt;
  DateTime? _petsLoadedAt;
  DateTime? _groomingPackagesLoadedAt;
  DateTime? _groomingAvailabilityLoadedAt;
  DateTime? _boardingRoomsLoadedAt;
  String? _lastDoctorDetailKey;

  List<Doctor> get doctors => _doctors;
  List<DoctorServiceItem> get doctorServices => _doctorServices;
  Map<String, dynamic>? get doctorAvailability => _doctorAvailability;
  List<PackageType> get groomingPackages => _groomingPackages;
  Map<String, dynamic>? get groomingAvailability => _groomingAvailability;
  List<BoardingRoom> get boardingRooms => _boardingRooms;
  List<Pet> get pets => _pets;

  Future<List<Doctor>> loadDoctors({bool forceRefresh = false}) async {
    if (!forceRefresh && _doctors.isNotEmpty && isCacheValid(_doctorsLoadedAt)) {
      return _doctors;
    }

    final result = await runBusy(ApiService.getDoctors);
    _doctors = result ?? const [];
    _doctorsLoadedAt = DateTime.now();
    notifyListeners();
    return _doctors;
  }

  Future<void> loadDoctorDetail({required int doctorId, int days = 6, bool forceRefresh = false}) async {
    final key = '$doctorId|$days';
    if (!forceRefresh &&
        _doctorServices.isNotEmpty &&
        _doctorAvailability != null &&
        _lastDoctorDetailKey == key &&
        isCacheValid(_doctorDetailLoadedAt)) {
      return;
    }

    await runBusy(() async {
      final results = await Future.wait([
        ApiService.getDoctorServices(doctorId: doctorId),
        ApiService.getDoctorAvailability(doctorId: doctorId, days: days),
      ]);
      _doctorServices = results[0] as List<DoctorServiceItem>;
      _doctorAvailability = results[1] as Map<String, dynamic>;
      _lastDoctorDetailKey = key;
      _doctorDetailLoadedAt = DateTime.now();
    });
    notifyListeners();
  }

  Future<List<Pet>> loadPets({bool forceRefresh = false}) async {
    if (!forceRefresh && _pets.isNotEmpty && isCacheValid(_petsLoadedAt)) return _pets;

    final result = await runBusy(ApiService.getMyPets);
    _pets = result ?? const [];
    _petsLoadedAt = DateTime.now();
    notifyListeners();
    return _pets;
  }

  Future<Map<String, dynamic>?> bookDoctor({
    required int idHewan,
    required int idDokter,
    required int idLayanan,
    int? idJadwal,
    required String tanggalBooking,
    required String jamBooking,
    String? keluhan,
  }) {
    return runBusy(() => ApiService.bookDoctor(
          idHewan: idHewan,
          idDokter: idDokter,
          idLayanan: idLayanan,
          idJadwal: idJadwal,
          tanggalBooking: tanggalBooking,
          jamBooking: jamBooking,
          keluhan: keluhan,
        ));
  }

  Future<List<PackageType>> loadGroomingPackages({bool forceRefresh = false}) async {
    if (!forceRefresh && _groomingPackages.isNotEmpty && isCacheValid(_groomingPackagesLoadedAt)) {
      return _groomingPackages;
    }

    final result = await runBusy(ApiService.getGroomingPackages);
    _groomingPackages = result ?? const [];
    _groomingPackagesLoadedAt = DateTime.now();
    notifyListeners();
    return _groomingPackages;
  }

  Future<Map<String, dynamic>?> loadGroomingAvailability({bool forceRefresh = false}) async {
    if (!forceRefresh && _groomingAvailability != null && isCacheValid(_groomingAvailabilityLoadedAt)) {
      return _groomingAvailability;
    }

    final result = await runBusy(ApiService.getGroomingAvailability);
    _groomingAvailability = result;
    _groomingAvailabilityLoadedAt = DateTime.now();
    notifyListeners();
    return result;
  }

  Future<void> loadGroomingFormData({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _pets.isNotEmpty &&
        _groomingAvailability != null &&
        isCacheValid(_petsLoadedAt) &&
        isCacheValid(_groomingAvailabilityLoadedAt)) {
      return;
    }

    await runBusy(() async {
      final results = await Future.wait([
        ApiService.getMyPets(),
        ApiService.getGroomingAvailability(),
      ]);
      _pets = results[0] as List<Pet>;
      _groomingAvailability = results[1] as Map<String, dynamic>;
      _petsLoadedAt = DateTime.now();
      _groomingAvailabilityLoadedAt = DateTime.now();
    });
    notifyListeners();
  }

  Future<bool> bookGrooming({
    required int idHewan,
    required int idPaket,
    required String tanggalGrooming,
    required String waktuGrooming,
    String? catatanGrooming,
  }) {
    return runAction(() => ApiService.bookGrooming(
          idHewan: idHewan,
          idPaket: idPaket,
          tanggalGrooming: tanggalGrooming,
          waktuGrooming: waktuGrooming,
          catatanGrooming: catatanGrooming,
        ));
  }

  Future<List<BoardingRoom>> loadBoardingRooms({bool forceRefresh = false}) async {
    if (!forceRefresh && _boardingRooms.isNotEmpty && isCacheValid(_boardingRoomsLoadedAt)) {
      return _boardingRooms;
    }

    final result = await runBusy(ApiService.getBoardingRooms);
    _boardingRooms = result ?? const [];
    _boardingRoomsLoadedAt = DateTime.now();
    notifyListeners();
    return _boardingRooms;
  }

  Future<Map<String, dynamic>?> estimateBoarding({
    required int idKamar,
    required String tanggalMasuk,
    required String tanggalRencanaKeluar,
  }) {
    return runBusy(() => ApiService.estimateBoarding(
          idKamar: idKamar,
          tanggalMasuk: tanggalMasuk,
          tanggalRencanaKeluar: tanggalRencanaKeluar,
        ));
  }

  Future<Map<String, dynamic>?> bookBoarding({
    required int idHewan,
    required int idKamar,
    required String tanggalMasuk,
    required String tanggalRencanaKeluar,
    String? catatan,
  }) {
    return runBusy(() => ApiService.bookBoarding(
          idHewan: idHewan,
          idKamar: idKamar,
          tanggalMasuk: tanggalMasuk,
          tanggalRencanaKeluar: tanggalRencanaKeluar,
          catatan: catatan,
        ));
  }

  void clearCache() {
    _doctorsLoadedAt = null;
    _doctorDetailLoadedAt = null;
    _petsLoadedAt = null;
    _groomingPackagesLoadedAt = null;
    _groomingAvailabilityLoadedAt = null;
    _boardingRoomsLoadedAt = null;
    _lastDoctorDetailKey = null;
  }
}
