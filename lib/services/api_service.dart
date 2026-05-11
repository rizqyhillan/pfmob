import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/profile/medical_report.dart';
import '../screens/profile/shop_report.dart';
import '../screens/profile/transaction_detail.dart';
import '../config/api_config.dart';

class UserProfile {
  final int id;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;

  UserProfile({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }
}

class Pet {
  final int id;
  final String nama;
  final String jenis;
  final String jenisKelamin;
  final String tanggalLahir;
  final String ras;
  final String umur;
  final String berat;
  final String catatan;
  final String foto;

  Pet({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.ras,
    required this.umur,
    required this.berat,
    required this.catatan,
    required this.foto,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? 0,
      nama: json['nama_hewan'] ?? '-',
      jenis: json['jenis'] ?? '-',
      jenisKelamin: json['jenis_kelamin'] ?? '-',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      ras: json['ras'] ?? '-',
      umur: json['umur'] ?? '-',
      berat: json['berat']?.toString() ?? '',
      catatan: json['catatan'] ?? '',
      foto: json['foto'] ?? '',
    );
  }
}

class ApiService {
static const String baseUrl = ApiConfig.baseUrl;

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

  static Future<UserProfile> getProfile() async {
  final response = await http.get(
    Uri.parse('$baseUrl/profile'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return UserProfile.fromJson(body['data']);
  } else if (response.statusCode == 401) {
    throw Exception('Sesi habis, silakan login kembali.');
  } else {
    throw Exception('Gagal memuat profil');
  }
}

static Future<UserProfile> updateProfile({
  required String nama,
  required String noHp,
  required String alamat,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/profile'),
    headers: _headers,
    body: jsonEncode({
      'nama': nama,
      'no_hp': noHp,
      'alamat': alamat,
    }),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return UserProfile.fromJson(body['data']);
  } else if (response.statusCode == 401) {
    throw Exception('Sesi habis, silakan login kembali.');
  } else {
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Gagal memperbarui profil');
  }
}

static Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/change-password'),
    headers: _headers,
    body: jsonEncode({
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else if (response.statusCode == 401) {
    throw Exception('Sesi habis, silakan login kembali.');
  } else {
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Gagal mengubah password');
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

  static Future<List<Pet>> getMyPets() async {
  final response = await http.get(
    Uri.parse('$baseUrl/my-pets'),
    headers: _headers,
  );

  final list = _parseList(response, 'data hewan');
  return list.map((e) => Pet.fromJson(e)).toList();
}

static Future<void> addPet({
  required String namaHewan,
  required String jenis,
  String? jenisKelamin,
  String? tanggalLahir,
  String? ras,
  String? umur,
  String? berat,
  String? catatan,
  String? foto,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/my-pets'),
    headers: _headers,
    body: jsonEncode({
      'nama_hewan': namaHewan,
      'jenis': jenis,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'ras': ras,
      'umur': umur,
      'berat': berat,
      'catatan': catatan,
      'foto': foto,
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return;
  }

  final body = jsonDecode(response.body);
  throw Exception(body['message'] ?? 'Gagal menambahkan hewan');
}

static Future<void> updatePet({
  required int id,
  required String namaHewan,
  required String jenis,
  String? jenisKelamin,
  String? tanggalLahir,
  String? ras,
  String? umur,
  String? berat,
  String? catatan,
  String? foto,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/my-pets/$id'),
    headers: _headers,
    body: jsonEncode({
      'nama_hewan': namaHewan,
      'jenis': jenis,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'ras': ras,
      'umur': umur,
      'berat': berat,
      'catatan': catatan,
      'foto': foto,
    }),
  );

  if (response.statusCode == 200) {
    return;
  }

  final body = jsonDecode(response.body);
  throw Exception(body['message'] ?? 'Gagal memperbarui data hewan');
}

static Future<void> deletePet(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/my-pets/$id'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    return;
  } else if (response.statusCode == 401) {
    throw Exception('Sesi habis, silakan login kembali.');
  } else if (response.statusCode == 404) {
    throw Exception('Data hewan tidak ditemukan.');
  } else {
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Gagal menghapus hewan');
  }
}
}