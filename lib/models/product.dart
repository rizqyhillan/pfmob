import 'package:flutter/material.dart';
import '../config/api_config.dart';

/// Unified Product Entity for PawPet.
///
/// Serves as the single source of truth for all product-related data structures,
/// resolving discrepancies between English API conventions and Indonesian DB column names.
class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  final int stock;
  final bool isFeatured;
  final int totalSold;
  final bool tersedia;
  final Color bgColor; // For Home Dashboard pastel grid visual consistency

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.stock,
    required this.isFeatured,
    required this.totalSold,
    required this.tersedia,
    required this.bgColor,
  });

  // ─── Backward compatibility getters for legacy ShopProduct ───
  String get namaBarang => name;
  double get harga => price;
  int get stok => stock;
  String get kategori => category;

  /// Factory constructor to parse JSON from both Shop and Best Seller responses.
  ///
  /// Built to be bilingual, fully null-safe, type-safe, and tolerant of missing fields.
  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 0;

    // Bilingual / Tolerant name mapping
    final name = json['nama_barang'] ?? json['name'] ?? json['nama'] ?? '-';

    // Bilingual / Tolerant price mapping
    final price = double.tryParse((json['harga'] ?? json['price'] ?? 0).toString()) ?? 0.0;

    // Bilingual / Tolerant category mapping
    final category = json['kategori'] ?? json['category'] ?? 'General';

    // Bilingual / Tolerant stock mapping
    final stock = int.tryParse((json['stok'] ?? json['stock'] ?? 0).toString()) ?? 0;

    // Bilingual / Tolerant features mapping
    final isFeatured = json['is_featured'] == true ||
        json['featured'] == true ||
        (json['is_featured'] != null && int.tryParse(json['is_featured'].toString()) == 1);

    // Bilingual / Tolerant sales mapping
    final totalSold = int.tryParse((json['total_sold'] ?? json['sold_count'] ?? json['terjual'] ?? 0).toString()) ?? 0;

    // Bilingual / Tolerant availability mapping
    final tersedia = json['tersedia'] == true ||
        json['available'] == true ||
        (json['tersedia'] != null && int.tryParse(json['tersedia'].toString()) == 1) ||
        stock > 0;

    // Image URL resolution
    final rawImg = json['image_url'] ?? json['imageUrl'] ?? json['foto'] ?? '';
    final imageUrl = _resolveImageUrl(rawImg);

    return Product(
      id: id,
      name: name.toString().trim(),
      imageUrl: imageUrl,
      price: price,
      category: category.toString().trim(),
      stock: stock,
      isFeatured: isFeatured,
      totalSold: totalSold,
      tersedia: tersedia,
      bgColor: _bgColorFromId(id),
    );
  }

  /// Helper to convert relative Laravel storage path into fully-qualified network URL.
  static String _resolveImageUrl(dynamic raw) {
    final value = raw?.toString() ?? '';
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://') || value.startsWith('assets/')) {
      return value;
    }

    final serverBaseUrl = ApiConfig.baseUrl.replaceFirst('/api', '');
    final normalizedPath = value.startsWith('storage/')
        ? value.replaceFirst('storage/', '')
        : value;

    return '$serverBaseUrl/storage/$normalizedPath';
  }

  /// Generates a soft pastel background color based on product ID.
  /// Preserves the visual design system of the dashboard screen.
  static Color _bgColorFromId(int id) {
    const colors = [
      Color(0xFFFFF3E8), // Warm orange
      Color(0xFFE8F5F3), // Mint green
      Color(0xFFFFE8F0), // Soft pink
      Color(0xFFE8F4FF), // Light blue
    ];
    return colors[id % colors.length];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': name,
      'image_url': imageUrl,
      'harga': price,
      'kategori': category,
      'stok': stock,
      'is_featured': isFeatured ? 1 : 0,
      'total_sold': totalSold,
      'tersedia': tersedia ? 1 : 0,
    };
  }
}
