import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/profile/medical_report.dart';
import '../screens/profile/shop_report.dart';
import '../screens/profile/transaction_detail.dart';
import '../config/api_config.dart';
import 'dart:io';

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

  static String _resolveStorageUrl(dynamic raw) {
  final value = raw?.toString() ?? '';
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return '${ApiConfig.baseUrl.replaceFirst('/api', '')}/storage/$value';
  }

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
      foto: _resolveStorageUrl(json['foto']),
    );
  }
}

class PackageType {
  final int id;
  final String name;
  final String label;
  final String description;
  final String hargaPerMalam;
  final List<String> fasilitas;

  PackageType({
    required this.id,
    required this.name,
    required this.label,
    required this.description,
    required this.hargaPerMalam,
    required this.fasilitas,
  });

  factory PackageType.fromJson(Map<String, dynamic> json) {
    List<String> parseFasilitas = [];
    if (json['fasilitas'] != null) {
      if (json['fasilitas'] is List) {
        parseFasilitas = List<String>.from(json['fasilitas']);
      } else if (json['fasilitas'] is String) {
        // Jika masih string JSON
        try {
          final decoded = jsonDecode(json['fasilitas']);
          if (decoded is List) parseFasilitas = List<String>.from(decoded);
        } catch (_) {}
      }
    }

    return PackageType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      hargaPerMalam: json['harga_per_malam']?.toString() ?? '0',
      fasilitas: parseFasilitas,
    );
  }
}


class ShopProduct {
  final int id;
  final String namaBarang;
  final String kategori;
  final double harga;
  final int stok;
  final String? imageUrl;
  final bool tersedia;

  ShopProduct({
    required this.id,
    required this.namaBarang,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.imageUrl,
    required this.tersedia,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) => ShopProduct(
        id: json['id'] ?? 0,
        namaBarang: json['nama_barang'] ?? '-',
        kategori: json['kategori'] ?? '-',
        harga: double.tryParse(json['harga'].toString()) ?? 0,
        stok: int.tryParse(json['stok'].toString()) ?? 0,
        imageUrl: json['image_url'],
        tersedia: json['tersedia'] == true,
      );
}

class ShopCartItem {
  final int id;
  final int idBarang;
  final String namaBarang;
  final String kategori;
  final String? imageUrl;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final int stok;
  final bool tersedia;

  ShopCartItem({
    required this.id,
    required this.idBarang,
    required this.namaBarang,
    required this.kategori,
    this.imageUrl,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    required this.stok,
    required this.tersedia,
  });

  factory ShopCartItem.fromJson(Map<String, dynamic> json) => ShopCartItem(
        id: json['id'] ?? 0,
        idBarang: json['id_barang'] ?? 0,
        namaBarang: json['nama_barang'] ?? '-',
        kategori: json['kategori'] ?? '-',
        imageUrl: json['image_url'],
        jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
        hargaSatuan: double.tryParse(json['harga_satuan'].toString()) ?? 0,
        subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
        stok: int.tryParse(json['stok'].toString()) ?? 0,
        tersedia: json['tersedia'] == true,
      );
}

class ShopCart {
  final int id;
  final String status;
  final List<ShopCartItem> items;
  final int totalItem;
  final double totalHarga;

  ShopCart({
    required this.id,
    required this.status,
    required this.items,
    required this.totalItem,
    required this.totalHarga,
  });

  factory ShopCart.fromJson(Map<String, dynamic> json) => ShopCart(
        id: json['id'] ?? 0,
        status: json['status'] ?? '-',
        items: ((json['items'] ?? []) as List)
            .map((e) => ShopCartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalItem: int.tryParse(json['total_item'].toString()) ?? 0,
        totalHarga: double.tryParse(json['total_harga'].toString()) ?? 0,
      );
}

class Doctor {
  final int id;
  final String nama;
  final String spesialis;
  final String pengalaman;
  final double rating;
  final bool tersedia;

  Doctor({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.pengalaman,
    required this.rating,
    required this.tersedia,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? '-',
        spesialis: json['spesialis'] ?? 'Dokter Hewan',
        pengalaman: json['pengalaman'] ?? '-',
        rating: double.tryParse(json['rating'].toString()) ?? 0,
        tersedia: json['tersedia'] == true,
      );
}

class DoctorServiceItem {
  final int id;
  final String namaLayanan;
  final String deskripsi;
  final double harga;

  DoctorServiceItem({
    required this.id,
    required this.namaLayanan,
    required this.deskripsi,
    required this.harga,
  });

  factory DoctorServiceItem.fromJson(Map<String, dynamic> json) => DoctorServiceItem(
        id: json['id'] ?? 0,
        namaLayanan: json['nama_layanan'] ?? '-',
        deskripsi: json['deskripsi'] ?? '',
        harga: double.tryParse((json['estimasi_biaya'] ?? json['harga'] ?? 0).toString()) ?? 0,
      );
}

class DoctorScheduleItem {
  final int id;
  final int idDokter;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  DoctorScheduleItem({
    required this.id,
    required this.idDokter,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory DoctorScheduleItem.fromJson(Map<String, dynamic> json) => DoctorScheduleItem(
        id: json['id'] ?? 0,
        idDokter: json['id_dokter'] ?? 0,
        hari: json['hari'] ?? '-',
        jamMulai: json['jam_mulai'] ?? '',
        jamSelesai: json['jam_selesai'] ?? '',
      );
}

class BoardingRoom {
  final int id;
  final String namaKamar;
  final String paket;
  final int kapasitas;
  final int terisi;
  final int sisaKapasitas;
  final double hargaPerHari;
  final List<String> fasilitas;
  final bool tersedia;

  BoardingRoom({
    required this.id,
    required this.namaKamar,
    required this.paket,
    required this.kapasitas,
    required this.terisi,
    required this.sisaKapasitas,
    required this.hargaPerHari,
    required this.fasilitas,
    required this.tersedia,
  });

  factory BoardingRoom.fromJson(Map<String, dynamic> json) {
    final raw = json['fasilitas'];
    List<String> fasilitas = [];
    if (raw is List) fasilitas = raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) fasilitas = decoded.map((e) => e.toString()).toList();
      } catch (_) {
        fasilitas = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return BoardingRoom(
      id: json['id'] ?? 0,
      namaKamar: json['nama_kamar'] ?? '-',
      paket: json['paket'] ?? '-',
      kapasitas: int.tryParse(json['kapasitas'].toString()) ?? 0,
      terisi: int.tryParse(json['terisi'].toString()) ?? 0,
      sisaKapasitas: int.tryParse(json['sisa_kapasitas'].toString()) ?? 0,
      hargaPerHari: double.tryParse(json['harga_per_hari'].toString()) ?? 0,
      fasilitas: fasilitas,
      tersedia: json['tersedia'] == true,
    );
  }
}

class AppScheduleItem {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String status;
  final String emoji;

  AppScheduleItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.status,
    required this.emoji,
  });

  bool get isHistory {
    final s = status.toLowerCase();
    return s == 'selesai' || s == 'batal' || s == 'dibatalkan' || s == 'cancelled';
  }

  factory AppScheduleItem.fromDoctorJson(Map<String, dynamic> json) {
    final petName = json['nama_hewan']?.toString() ?? '-';
    final petType = json['jenis_hewan']?.toString() ?? '-';
    final doctorName = json['nama_dokter']?.toString() ?? '-';

    return AppScheduleItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: 'doctor',
      title: json['nama_layanan']?.toString() ?? 'Konsultasi Dokter',
      subtitle: '$petName • $petType • drh. $doctorName',
      date: json['tanggal_booking']?.toString() ?? '-',
      time: _shortTime(json['jam_booking']?.toString()),
      status: json['status']?.toString() ?? 'pending',
      emoji: '🩺',
    );
  }

  factory AppScheduleItem.fromBoardingJson(Map<String, dynamic> json) {
    final petName = json['nama_hewan']?.toString() ?? '-';
    final petType = json['jenis_hewan']?.toString() ?? '-';
    final roomName = json['nama_kamar']?.toString() ?? '-';

    return AppScheduleItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: 'boarding',
      title: 'Penitipan $roomName',
      subtitle: '$petName • $petType',
      date: json['tanggal_masuk']?.toString() ?? '-',
      time: 'Check-in',
      status: json['status']?.toString() ?? 'pending',
      emoji: '🏠',
    );
  }

  static String _shortTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw;
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

  static Future<ShopCart> addCartItem({required int idBarang, required int jumlah}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shop/cart/items'),
      headers: _headers,
      body: jsonEncode({'id_barang': idBarang, 'jumlah': jumlah}),
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
        if (catatan != null) 'catatan': catatan,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = _decodeMap(response);
      return Map<String, dynamic>.from(body['data']);
    }
    _throwApiError(response, 'Gagal membuat booking penitipan');
    throw Exception('Gagal membuat booking penitipan');
  }

  static Future<Map<String, dynamic>> updateProfile({
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
        return Map<String, dynamic>.from(body['data'] ?? {});
        }

        throw Exception(body['message'] ?? 'Gagal memperbarui profil');
      }

}   