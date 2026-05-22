import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';
import 'servis_auth.dart';

/// Central Repository for all Product-related data operations in PawPet.
///
/// Implements the "Single Source of Truth" architectural pattern,
/// fetching, parsing, and providing fallback strategies for both
/// normal products and best seller/featured products.
class ProductRepository {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Private helper to get default headers with dynamic authorization token
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (AuthService().token.isNotEmpty) 'Authorization': 'Bearer ${AuthService().token}',
      };

  /// Fetch products list from backend with search and category filters.
  ///
  /// Hits: `GET /api/shop/products`
  Future<List<Product>> getProducts({String? search, String? kategori}) async {
    try {
      final uri = Uri.parse('$baseUrl/shop/products').replace(queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (kategori != null && kategori.trim().isNotEmpty && kategori != 'All' && kategori != 'Semua')
          'kategori': kategori.trim(),
      });

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        final List<dynamic> list = body is List ? body : (body['data'] ?? []);
        return list.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi habis, silakan login kembali.');
      } else {
        throw Exception('Server mengembalikan status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data produk: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  /// Fetch best seller / featured products list from backend.
  ///
  /// Hits: `GET /api/shop/products/best-sellers`
  ///
  /// Fallback Strategy:
  /// - If the endpoint returns 401 (guest user) or fails to fetch,
  ///   or if no best sellers are configured (empty list):
  ///   1. Fetch all active shop products.
  ///   2. Filter products marked as `isFeatured = true` (up to 4).
  ///   3. If no featured products exist, fallback to the 4 newest/first available products.
  /// This ensures zero-crash guarantee in guest mode or on empty databases.
  Future<List<Product>> getBestSellerProducts() async {
    try {
      final uri = Uri.parse('$baseUrl/shop/products/best-sellers');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        final List<dynamic> list = body is List ? body : (body['data'] ?? []);
        final products = list.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
        
        if (products.isNotEmpty) {
          return products;
        }
      }
      
      // Fallback 1: Database empty of best-sellers, or HTTP error (e.g. 401 guest mode restriction)
      return await _getFallbackProducts();
    } catch (_) {
      // Fallback 2: General network/server exception
      return await _getFallbackProducts();
    }
  }

  /// Fallback helper to fetch general products and filter featured/first 4 products
  Future<List<Product>> _getFallbackProducts() async {
    try {
      final allProducts = await getProducts();
      if (allProducts.isEmpty) return [];

      // Try to get featured ones
      final featured = allProducts.where((p) => p.isFeatured).toList();
      if (featured.isNotEmpty) {
        return featured.take(4).toList();
      }

      // Default: take first 4 products
      return allProducts.take(4).toList();
    } catch (e) {
      // Return empty list instead of throwing to prevent landing dashboard crashes
      return [];
    }
  }

  /// Get featured products (Alias for getBestSellerProducts for clean code references)
  Future<List<Product>> getFeaturedProducts() => getBestSellerProducts();

  /// Fetch single product detail from backend by ID.
  ///
  /// Hits: `GET /api/shop/products/{id}`
  Future<Product> getProductDetail(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/shop/products/$id');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map && decoded['data'] != null ? decoded['data'] : decoded;
        return Product.fromJson(Map<String, dynamic>.from(data));
      } else if (response.statusCode == 404) {
        throw Exception('Produk tidak ditemukan di server.');
      } else {
        throw Exception('Server mengembalikan status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail produk: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}
