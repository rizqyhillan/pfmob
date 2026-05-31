import '../models/medical_record.dart';
import '../models/transaction.dart';
import '../models/transaction_detail.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ReportViewModel extends BaseViewModel {
  List<MedicalRecord> _medicalRecords = const [];
  List<Transaction> _transactions = const [];
  TransactionDetail? _selectedTransaction;

  DateTime? _medicalRecordsLoadedAt;
  DateTime? _transactionsLoadedAt;
  DateTime? _selectedTransactionLoadedAt;
  int? _selectedTransactionId;
  int? _lastMedicalPetId;
  String? _lastTransactionStatus;

  List<MedicalRecord> get medicalRecords => _medicalRecords;
  List<Transaction> get transactions => _transactions;
  TransactionDetail? get selectedTransaction => _selectedTransaction;

  Future<List<MedicalRecord>> loadMedicalRecords({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastMedicalPetId == null &&
        _medicalRecords.isNotEmpty &&
        isCacheValid(_medicalRecordsLoadedAt)) {
      return _medicalRecords;
    }

    final result = await runBusy(ApiService.getMedicalRecords);
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat rekam medis');
    _medicalRecords = result;
    _lastMedicalPetId = null;
    _medicalRecordsLoadedAt = DateTime.now();
    notifyListeners();
    return _medicalRecords;
  }

  Future<List<MedicalRecord>> loadMedicalRecordsByPet(int petId, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastMedicalPetId == petId &&
        _medicalRecords.isNotEmpty &&
        isCacheValid(_medicalRecordsLoadedAt)) {
      return _medicalRecords;
    }

    final result = await runBusy(() => ApiService.getMedicalRecordsByPet(petId));
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat rekam medis hewan');
    _medicalRecords = result;
    _lastMedicalPetId = petId;
    _medicalRecordsLoadedAt = DateTime.now();
    notifyListeners();
    return _medicalRecords;
  }

  Future<List<Transaction>> loadTransactions({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastTransactionStatus == null &&
        _transactions.isNotEmpty &&
        isCacheValid(_transactionsLoadedAt)) {
      return _transactions;
    }

    final result = await runBusy(ApiService.getTransactions);
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat transaksi');
    _transactions = result;
    _lastTransactionStatus = null;
    _transactionsLoadedAt = DateTime.now();
    notifyListeners();
    return _transactions;
  }

  Future<List<Transaction>> loadTransactionsByStatus(String status, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastTransactionStatus == status &&
        _transactions.isNotEmpty &&
        isCacheValid(_transactionsLoadedAt)) {
      return _transactions;
    }

    final result = await runBusy(() => ApiService.getTransactionsByStatus(status));
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat transaksi');
    _transactions = result;
    _lastTransactionStatus = status;
    _transactionsLoadedAt = DateTime.now();
    notifyListeners();
    return _transactions;
  }

  Future<TransactionDetail> loadTransactionDetail(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _selectedTransactionId == id &&
        _selectedTransaction != null &&
        isCacheValid(_selectedTransactionLoadedAt)) {
      return _selectedTransaction!;
    }

    final result = await runBusy(() => ApiService.getTransactionDetail(id));
    if (result == null) throw Exception(errorMessage ?? 'Gagal memuat detail transaksi');
    _selectedTransaction = result;
    _selectedTransactionId = id;
    _selectedTransactionLoadedAt = DateTime.now();
    notifyListeners();
    return result;
  }

  void clearCache() {
    _medicalRecordsLoadedAt = null;
    _transactionsLoadedAt = null;
    _selectedTransactionLoadedAt = null;
    _selectedTransactionId = null;
    _lastMedicalPetId = null;
    _lastTransactionStatus = null;
  }
}
