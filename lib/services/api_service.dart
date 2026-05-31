import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/models.dart';

export '../models/models.dart';

class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;

  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  static Map<String, String> get _multipartHeaders => {
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

  static void _addMultipartField(
  http.MultipartRequest request,
  String key,
  String? value,
  ) {
    if (value != null && value.trim().isNotEmpty) {
      request.fields[key] = value.trim();
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

  // ════════════════════════════════════════════════════════════
  // GROOMING
  // ════════════════════════════════════════════════════════════

  static Future<List<PackageType>> getGroomingPackages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grooming/packages'),
      headers: _headers,
    );
    final list = _parseList(response, 'paket grooming');
    return list.map((e) => PackageType.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> getGroomingAvailability() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grooming/availability'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis, silakan login kembali.');
    } else {
      throw Exception('Gagal mengambil jadwal grooming');
    }
  }

  static Future<void> bookGrooming({
    required int idHewan,
    required int idPaket,
    required String tanggalGrooming,
    required String waktuGrooming,
    String? catatanGrooming,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grooming/book'),
      headers: _headers,
      body: jsonEncode({
        'id_hewan': idHewan,
        'id_paket': idPaket,
        'tanggal_grooming': tanggalGrooming,
        'waktu_grooming': waktuGrooming,
        if (catatanGrooming != null) 'catatan_grooming': catatanGrooming,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis, silakan login kembali.');
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal membuat booking grooming');
    }
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
  File? fotoFile,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/my-pets'),
  );

  request.headers.addAll(_multipartHeaders);

  request.fields['nama_hewan'] = namaHewan;
  request.fields['jenis'] = jenis;

  _addMultipartField(request, 'jenis_kelamin', jenisKelamin);
  _addMultipartField(request, 'tanggal_lahir', tanggalLahir);
  _addMultipartField(request, 'ras', ras);
  _addMultipartField(request, 'umur', umur);
  _addMultipartField(request, 'berat', berat);
  _addMultipartField(request, 'catatan', catatan);

  if (fotoFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath('foto', fotoFile.path),
    );
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

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
  File? fotoFile,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/my-pets/$id'),
  );

  request.headers.addAll(_multipartHeaders);

  // Laravel route update normalnya PUT/PATCH.
  // Multipart dari mobile lebih aman dikirim POST + _method=PUT.
  request.fields['_method'] = 'PUT';

  request.fields['nama_hewan'] = namaHewan;
  request.fields['jenis'] = jenis;

  _addMultipartField(request, 'jenis_kelamin', jenisKelamin);
  _addMultipartField(request, 'tanggal_lahir', tanggalLahir);
  _addMultipartField(request, 'ras', ras);
  _addMultipartField(request, 'umur', umur);
  _addMultipartField(request, 'berat', berat);
  _addMultipartField(request, 'catatan', catatan);

  if (fotoFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath('foto', fotoFile.path),
    );
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

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

  static Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  static void _throwApiError(http.Response response, String fallback) {
    if (response.statusCode == 401) {
      throw Exception('Sesi habis, silakan login kembali.');
    }
    try {
      final body = _decodeMap(response);
      throw Exception(body['message'] ?? fallback);
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) rethrow;
      throw Exception(fallback);
    }
  }

  // ════════════════════════════════════════════════════════════
  // SHOP / PRODUK / KERANJANG
  // ════════════════════════════════════════════════════════════

  static Future<List<ShopProduct>> getShopProducts({String? search, String? kategori}) async {
    final uri = Uri.parse('$baseUrl/shop/products').replace(queryParameters: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (kategori != null && kategori.trim().isNotEmpty && kategori != 'All') 'kategori': kategori.trim(),
    });
    final response = await http.get(uri, headers: _headers);
    final list = _parseList(response, 'produk');
    return list.map((e) => ShopProduct.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<String>> getShopCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/shop/categories'), headers: _headers);
    final list = _parseList(response, 'kategori produk');
    return list.map((e) => e.toString()).toList();
  }

  static Future<ShopProduct> getShopProductDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shop/products/$id'), headers: _headers);
    if (response.statusCode == 200) {
      final body = _decodeMap(response);
      return ShopProduct.fromJson(Map<String, dynamic>.from(body['data']));
    }
    _throwApiError(response, 'Gagal mengambil detail produk');
    throw Exception('Gagal mengambil detail produk');
  }

  static Future<ShopCart> getCart() async {
    final response = await http.get(Uri.parse('$baseUrl/shop/cart'), headers: _headers);
    if (response.statusCode == 200) {
      final body = _decodeMap(response);
      return ShopCart.fromJson(Map<String, dynamic>.from(body['data']));
    }
    _throwApiError(response, 'Gagal mengambil keranjang');
    throw Exception('Gagal mengambil keranjang');
  }

  static Future<ShopCart> addCartItem({required int idBarang, required int jumlah, int? idVariasi}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shop/cart/items'),
      headers: _headers,
      body: jsonEncode({
        'id_barang': idBarang,
        'jumlah': jumlah,
        if (idVariasi != null) 'id_variasi': idVariasi,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = _decodeMap(response);
      return ShopCart.fromJson(Map<String, dynamic>.from(body['data']));
    }
    _throwApiError(response, 'Gagal menambahkan produk ke keranjang');
    throw Exception('Gagal menambahkan produk ke keranjang');
  }

  static Future<ShopCart> updateCartItem({required int itemId, required int jumlah}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/shop/cart/items/$itemId'),
      headers: _headers,
      body: jsonEncode({'jumlah': jumlah}),
    );
    if (response.statusCode == 200) {
      final body = _decodeMap(response);
      return ShopCart.fromJson(Map<String, dynamic>.from(body['data']));
    }
    _throwApiError(response, 'Gagal memperbarui keranjang');
    throw Exception('Gagal memperbarui keranjang');
  }

  static Future<ShopCart> removeCartItem(int itemId) async {
    final response = await http.delete(Uri.parse('$baseUrl/shop/cart/items/$itemId'), headers: _headers);
    if (response.statusCode == 200) {
      final body = _decodeMap(response);
      return ShopCart.fromJson(Map<String, dynamic>.from(body['data']));
    }
    _throwApiError(response, 'Gagal menghapus item keranjang');
    throw Exception('Gagal menghapus item keranjang');
  }

  static Future<Map<String, dynamic>> checkoutCart({String? catatan, String metodeBayar = 'ewallet'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shop/checkout'),
      headers: _headers,
      body: jsonEncode({'metode_bayar': metodeBayar, if (catatan != null) 'catatan': catatan}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = _decodeMap(response);
      return Map<String, dynamic>.from(body['data']);
    }
    _throwApiError(response, 'Gagal checkout keranjang');
    throw Exception('Gagal checkout keranjang');
  }

  // ════════════════════════════════════════════════════════════
  // DOCTOR BOOKING
  // ════════════════════════════════════════════════════════════

  static Future<List<Doctor>> getDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/doctors'), headers: _headers);
    debugPrint('PAWPET_DEBUG: GET /api/doctors response = ${response.body}');
    final list = _parseList(response, 'dokter');
    return list.map((e) => Doctor.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<DoctorServiceItem>> getDoctorServices({int? doctorId}) async {
    final uri = Uri.parse('$baseUrl/doctor-services').replace(queryParameters: {
      if (doctorId != null) 'doctor_id': doctorId.toString(),
    });
    final response = await http.get(uri, headers: _headers);
    final list = _parseList(response, 'layanan dokter');
    return list.map((e) => DoctorServiceItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<DoctorScheduleItem>> getDoctorSchedules({int? doctorId}) async {
    final uri = Uri.parse('$baseUrl/doctor-schedules').replace(queryParameters: {
      if (doctorId != null) 'doctor_id': doctorId.toString(),
    });
    final response = await http.get(uri, headers: _headers);
    final list = _parseList(response, 'jadwal dokter');
    return list.map((e) => DoctorScheduleItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<Map<String, dynamic>> getDoctorAvailability({
    required int doctorId,
    int days = 6,
  }) async {
    final uri = Uri.parse('$baseUrl/doctor-availability').replace(
      queryParameters: {
        'doctor_id': doctorId.toString(),
        'days': days.toString(),
      },
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = _decodeMap(response);
      return Map<String, dynamic>.from(body['data']);
    }

    _throwApiError(response, 'Gagal mengambil jadwal dokter');
    throw Exception('Gagal mengambil jadwal dokter');
  }

  static Future<List<AppScheduleItem>> getMyDoctorBookings() async {
  final response = await http.get(
    Uri.parse('$baseUrl/my-doctor-bookings'),
    headers: _headers,
  );

  final list = _parseList(response, 'booking dokter');
  return list
      .map((e) => AppScheduleItem.fromDoctorJson(Map<String, dynamic>.from(e)))
      .toList();
  }

  static Future<List<AppScheduleItem>> getMyGroomingBookings() async {
  final response = await http.get(
    Uri.parse('$baseUrl/my-grooming-bookings'),
    headers: _headers,
    );
    final list = _parseList(response, 'booking grooming');
    return list
    .map((e) => AppScheduleItem.fromGroomingJson(Map<String, dynamic>.from(e)))
    .toList();
  }

  static Future<Map<String, dynamic>> bookDoctor({
    required int idHewan,
    required int idDokter,
    required int idLayanan,
    int? idJadwal,
    required String tanggalBooking,
    required String jamBooking,
    String? keluhan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor-bookings'),
      headers: _headers,
      body: jsonEncode({
        'id_hewan': idHewan,
        'id_dokter': idDokter,
        'id_layanan': idLayanan,
        if (idJadwal != null) 'id_jadwal': idJadwal,
        'tanggal_booking': tanggalBooking,
        'jam_booking': jamBooking,
        if (keluhan != null) 'keluhan': keluhan,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = _decodeMap(response);
      return Map<String, dynamic>.from(body['data']);
    }
    _throwApiError(response, 'Gagal membuat booking dokter');
    throw Exception('Gagal membuat booking dokter');
  }

  static Future<Map<String, dynamic>> cancelDoctorBooking(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor-bookings/$id/cancel'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(_decodeMap(response)['data']);
    }
    _throwApiError(response, 'Gagal membatalkan booking dokter');
    throw Exception('Gagal membatalkan booking dokter');
  }

  static Future<Map<String, dynamic>> cancelGroomingBooking(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grooming-bookings/$id/cancel'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(_decodeMap(response)['data']);
    }
    _throwApiError(response, 'Gagal membatalkan booking grooming');
    throw Exception('Gagal membatalkan booking grooming');
  }

  static Future<Map<String, dynamic>> rescheduleDoctorBooking({
    required int id,
    required String tanggalBooking,
    required String jamBooking,
    int? idJadwal,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor-bookings/$id/reschedule'),
      headers: _headers,
      body: jsonEncode({
        'tanggal_booking': tanggalBooking,
        'jam_booking': jamBooking,
        if (idJadwal != null) 'id_jadwal': idJadwal,
      }),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(_decodeMap(response)['data']);
    }
    _throwApiError(response, 'Gagal mengubah jadwal dokter');
    throw Exception('Gagal mengubah jadwal dokter');
  }

  static Future<Map<String, dynamic>> rescheduleGroomingBooking({
    required int id,
    required String tanggalGrooming,
    required String waktuGrooming,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grooming-bookings/$id/reschedule'),
      headers: _headers,
      body: jsonEncode({
        'tanggal_grooming': tanggalGrooming,
        'waktu_grooming': waktuGrooming,
      }),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(_decodeMap(response)['data']);
    }
    _throwApiError(response, 'Gagal mengubah jadwal grooming');
    throw Exception('Gagal mengubah jadwal grooming');
  }

  // ════════════════════════════════════════════════════════════
  // BOARDING / PENITIPAN
  // ════════════════════════════════════════════════════════════

  static Future<List<AppScheduleItem>> getMyBoardings() async {
  final response = await http.get(
    Uri.parse('$baseUrl/my-boardings'),
    headers: _headers,
  );

  final list = _parseList(response, 'booking penitipan');
  return list
      .map((e) => AppScheduleItem.fromBoardingJson(Map<String, dynamic>.from(e)))
      .toList();
  }

  static Future<List<BoardingRoom>> getBoardingRooms() async {
    final response = await http.get(Uri.parse('$baseUrl/boarding/rooms'), headers: _headers);
    final list = _parseList(response, 'kamar penitipan');
    return list.map((e) => BoardingRoom.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<Map<String, dynamic>> estimateBoarding({
    required int idKamar,
    required String tanggalMasuk,
    required String tanggalRencanaKeluar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/boarding/estimate'),
      headers: _headers,
      body: jsonEncode({
        'id_kamar': idKamar,
        'tanggal_masuk': tanggalMasuk,
        'tanggal_rencana_keluar': tanggalRencanaKeluar,
      }),
    );
    if (response.statusCode == 200) {
      final body = _decodeMap(response);
      return Map<String, dynamic>.from(body['data']);
    }
    _throwApiError(response, 'Gagal menghitung estimasi penitipan');
    throw Exception('Gagal menghitung estimasi penitipan');
  }

  static Future<Map<String, dynamic>> bookBoarding({
    required int idHewan,
    required int idKamar,
    required String tanggalMasuk,
    required String tanggalRencanaKeluar,
    String? catatan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/boarding/book'),
      headers: _headers,
      body: jsonEncode({
        'id_hewan': idHewan,
        'id_kamar': idKamar,
        'tanggal_masuk': tanggalMasuk,
        'tanggal_rencana_keluar': tanggalRencanaKeluar,
        if (catatan != null && catatan.trim().isNotEmpty) 'catatan_titip': catatan.trim(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = _decodeMap(response);
      return Map<String, dynamic>.from(body['data']);
    }
    _throwApiError(response, 'Gagal membuat booking penitipan');
    throw Exception('Gagal membuat booking penitipan');
  }

  static Future<Map<String, dynamic>> cancelBoarding(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/boardings/$id/cancel'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(_decodeMap(response)['data']);
    }
    _throwApiError(response, 'Gagal membatalkan booking penitipan');
    throw Exception('Gagal membatalkan booking penitipan');
  }

  static Future<Map<String, dynamic>> rescheduleBoarding({
    required int id,
    required String tanggalMasuk,
    required String tanggalRencanaKeluar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/boardings/$id/reschedule'),
      headers: _headers,
      body: jsonEncode({
        'tanggal_masuk': tanggalMasuk,
        'tanggal_rencana_keluar': tanggalRencanaKeluar,
      }),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(_decodeMap(response)['data']);
    }
    _throwApiError(response, 'Gagal mengubah jadwal penitipan');
    throw Exception('Gagal mengubah jadwal penitipan');
  }

  static Future<UserProfile> updateProfile({
    required String nama,
    required String email,
    String? noHp,
    String? alamat,
    File? fotoFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile'),
    );
  
    request.headers.addAll(_multipartHeaders);
  
    request.fields['nama'] = nama;
    request.fields['email'] = email;
  
    _addMultipartField(request, 'no_hp', noHp);
    _addMultipartField(request, 'alamat', alamat);
  
    if (fotoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', fotoFile.path),
      );
    }
  
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
  
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(response.body));
  
    if (response.statusCode == 200) {
      return UserProfile.fromJson(Map<String, dynamic>.from(body['data'] ?? {}));
    }
  
    if (response.statusCode == 401) {
      throw Exception('Sesi habis, silakan login kembali.');
    }
  
    throw Exception(body['message'] ?? 'Gagal memperbarui profil');
  }
  }   