import '../models/models.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ScheduleViewModel extends BaseViewModel {
  List<AppScheduleItem> _items = const [];
  List<Doctor> _doctors = const [];
  DateTime? _schedulesLoadedAt;

  List<AppScheduleItem> get items => _items;
  List<Doctor> get doctors => _doctors;
  List<AppScheduleItem> get upcomingItems => _items.where((item) => !item.isHistory).toList(growable: false);
  List<AppScheduleItem> get historyItems => _items.where((item) => item.isHistory).toList(growable: false);

  Future<void> loadSchedules({bool forceRefresh = false}) async {
    if (!forceRefresh && _items.isNotEmpty && isCacheValid(_schedulesLoadedAt)) return;

    await runBusy(() async {
      final results = await Future.wait([
        ApiService.getMyDoctorBookings(),
        ApiService.getMyGroomingBookings(),
        ApiService.getMyBoardings(),
        ApiService.getDoctors(),
      ]);
      final all = <AppScheduleItem>[
        ...(results[0] as List<AppScheduleItem>),
        ...(results[1] as List<AppScheduleItem>),
        ...(results[2] as List<AppScheduleItem>),
      ];
      all.sort((a, b) => a.date.compareTo(b.date));
      _items = all;
      _doctors = results[3] as List<Doctor>;
      _schedulesLoadedAt = DateTime.now();
    });
    notifyListeners();
  }

  Future<bool> cancelSchedule(AppScheduleItem item) async {
    final result = await runBusy(() async {
      switch (item.type) {
        case 'doctor':
          return ApiService.cancelDoctorBooking(item.id);
        case 'grooming':
          return ApiService.cancelGroomingBooking(item.id);
        case 'boarding':
          return ApiService.cancelBoarding(item.id);
        default:
          throw Exception('Tipe jadwal tidak dikenal');
      }
    });
    if (result != null) {
      await loadSchedules(forceRefresh: true);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> rescheduleDoctor({
    required int id,
    required String tanggalBooking,
    required String jamBooking,
    int? idJadwal,
  }) {
    return runBusy(() => ApiService.rescheduleDoctorBooking(
          id: id,
          tanggalBooking: tanggalBooking,
          jamBooking: jamBooking,
          idJadwal: idJadwal,
        ));
  }

  Future<Map<String, dynamic>?> rescheduleGrooming({
    required int id,
    required String tanggalGrooming,
    required String waktuGrooming,
  }) {
    return runBusy(() => ApiService.rescheduleGroomingBooking(
          id: id,
          tanggalGrooming: tanggalGrooming,
          waktuGrooming: waktuGrooming,
        ));
  }

  Future<Map<String, dynamic>?> rescheduleBoarding({
    required int id,
    required String tanggalMasuk,
    required String tanggalRencanaKeluar,
  }) {
    return runBusy(() => ApiService.rescheduleBoarding(
          id: id,
          tanggalMasuk: tanggalMasuk,
          tanggalRencanaKeluar: tanggalRencanaKeluar,
        ));
  }

  void clearCache() {
    _schedulesLoadedAt = null;
  }
}
