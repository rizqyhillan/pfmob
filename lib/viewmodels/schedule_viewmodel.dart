import '../models/models.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ScheduleViewModel extends BaseViewModel {
  List<AppScheduleItem> _items = const [];
  List<Doctor> _doctors = const [];

  List<AppScheduleItem> get items => _items;
  List<Doctor> get doctors => _doctors;
  List<AppScheduleItem> get upcomingItems => _items.where((item) => !item.isHistory).toList();
  List<AppScheduleItem> get historyItems => _items.where((item) => item.isHistory).toList();

  Future<void> loadSchedules() async {
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
      await loadSchedules();
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
}
