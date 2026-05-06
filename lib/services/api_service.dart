import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/profile/medical_report.dart';
import '../screens/profile/shop_report.dart';
import '../screens/profile/transaction_detail.dart';

class ApiService {
  // ════════════════════════════════════════════════════════════
  // 📌 Ganti BASE_URL sesuai kondisi:
  //    Emulator Android  → http://10.0.2.2:8000/api
  //    HP Fisik          → http://IP_KOMPUTERMU:8000/api
  //    Sudah di-deploy   → https://domain-kamu.com/api
  // ════════════════════════════════════════════════════════════
  static const String baseUrl = 'http://192.168.3.17:8000/api';

  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── Helper parse list response ──────────────────────────────
  static List<dynamic> _parseList(http.Response response, String endpoint) {
    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      if (body is List) return body;
      if (body is Map && body['data'] != null) return body['data'];
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis, silakan login kembali.');
    } else {
      throw Exception('Gagal mengambil $endpoint (${response.statusCode})');
    }
  }

  // ════════════════════════════════════════════════════════════
  // REKAM MEDIS
  // ════════════════════════════════════════════════════════════

  /// GET /api/medical-records
  static Future<List<MedicalRecord>> getMedicalRecords() async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records'),
      headers: _headers,
    );
    final list = _parseList(response, 'rekam medis');
    return list.map((e) => MedicalRecord.fromJson(e)).toList();
  }

  /// GET /api/medical-records/pet/{id}
  static Future<List<MedicalRecord>> getMedicalRecordsByPet(int petId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/pet/$petId'),
      headers: _headers,
    );
    final list = _parseList(response, 'rekam medis hewan');
    return list.map((e) => MedicalRecord.fromJson(e)).toList();
  }

  // ════════════════════════════════════════════════════════════
  // TRANSAKSI
  // ════════════════════════════════════════════════════════════

  /// GET /api/transactions
  /// List ringkas untuk shop_report.dart (tanpa barang & layanan)
  static Future<List<Transaction>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
    );
    final list = _parseList(response, 'transaksi');
    return list.map((e) => Transaction.fromJson(e)).toList();
  }

  /// GET /api/transactions/{id}
  /// Detail lengkap dengan barang & layanan untuk transaction_detail.dart
  /// ✅ Return type TransactionDetail, bukan Transaction
  static Future<TransactionDetail> getTransactionDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return TransactionDetail.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis, silakan login kembali.');
    } else if (response.statusCode == 404) {
      throw Exception('Transaksi tidak ditemukan.');
    } else {
      throw Exception(
          'Gagal mengambil detail transaksi (${response.statusCode})');
    }
  }

  /// GET /api/transactions/status/{status}
  /// status: lunas | pending | batal
  static Future<List<Transaction>> getTransactionsByStatus(
      String status) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/status/$status'),
      headers: _headers,
    );
    final list = _parseList(response, 'transaksi $status');
    return list.map((e) => Transaction.fromJson(e)).toList();
  }
}