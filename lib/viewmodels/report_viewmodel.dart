import '../models/medical_record.dart';
import '../models/transaction.dart';
import '../models/transaction_detail.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ReportViewModel extends BaseViewModel {
  List<MedicalRecord> _medicalRecords = const [];
  List<Transaction> _transactions = const [];
  TransactionDetail? _selectedTransaction;

  List<MedicalRecord> get medicalRecords => _medicalRecords;
  List<Transaction> get transactions => _transactions;
  TransactionDetail? get selectedTransaction => _selectedTransaction;

  Future<List<MedicalRecord>> loadMedicalRecords() async {
    final result = await runBusy(ApiService.getMedicalRecords);
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat rekam medis');
    _medicalRecords = result;
    notifyListeners();
    return _medicalRecords;
  }

  Future<List<MedicalRecord>> loadMedicalRecordsByPet(int petId) async {
    final result = await runBusy(() => ApiService.getMedicalRecordsByPet(petId));
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat rekam medis hewan');
    _medicalRecords = result;
    notifyListeners();
    return _medicalRecords;
  }

  Future<List<Transaction>> loadTransactions() async {
    final result = await runBusy(ApiService.getTransactions);
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat transaksi');
    _transactions = result;
    notifyListeners();
    return _transactions;
  }

  Future<List<Transaction>> loadTransactionsByStatus(String status) async {
    final result = await runBusy(() => ApiService.getTransactionsByStatus(status));
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat transaksi');
    _transactions = result;
    notifyListeners();
    return _transactions;
  }

  Future<TransactionDetail> loadTransactionDetail(int id) async {
    final result = await runBusy(() => ApiService.getTransactionDetail(id));
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat detail transaksi');
    _selectedTransaction = result;
    notifyListeners();
    return result;
  }
}
