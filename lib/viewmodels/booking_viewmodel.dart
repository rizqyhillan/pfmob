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

  List<Doctor> get doctors => _doctors;
  List<DoctorServiceItem> get doctorServices => _doctorServices;
  Map<String, dynamic>? get doctorAvailability => _doctorAvailability;
  List<PackageType> get groomingPackages => _groomingPackages;
  Map<String, dynamic>? get groomingAvailability => _groomingAvailability;
  List<BoardingRoom> get boardingRooms => _boardingRooms;
  List<Pet> get pets => _pets;

  Future<List<Doctor>> loadDoctors() async {
    final result = await runBusy(ApiService.getDoctors);
    _doctors = result ?? const [];
    notifyListeners();
    return _doctors;
  }

  Future<void> loadDoctorDetail({required int doctorId, int days = 6}) async {
    await runBusy(() async {
      final results = await Future.wait([
        ApiService.getDoctorServices(doctorId: doctorId),
        ApiService.getDoctorAvailability(doctorId: doctorId, days: days),
      ]);
      _doctorServices = results[0] as List<DoctorServiceItem>;
      _doctorAvailability = results[1] as Map<String, dynamic>;
    });
    notifyListeners();
  }

  Future<List<Pet>> loadPets() async {
    final result = await runBusy(ApiService.getMyPets);
    _pets = result ?? const [];
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

  Future<List<PackageType>> loadGroomingPackages() async {
    final result = await runBusy(ApiService.getGroomingPackages);
    _groomingPackages = result ?? const [];
    notifyListeners();
    return _groomingPackages;
  }

  Future<Map<String, dynamic>?> loadGroomingAvailability() async {
    final result = await runBusy(ApiService.getGroomingAvailability);
    _groomingAvailability = result;
    notifyListeners();
    return result;
  }

  Future<void> loadGroomingFormData() async {
    await runBusy(() async {
      final results = await Future.wait([
        ApiService.getMyPets(),
        ApiService.getGroomingAvailability(),
      ]);
      _pets = results[0] as List<Pet>;
      _groomingAvailability = results[1] as Map<String, dynamic>;
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

  Future<List<BoardingRoom>> loadBoardingRooms() async {
    final result = await runBusy(ApiService.getBoardingRooms);
    _boardingRooms = result ?? const [];
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
}
