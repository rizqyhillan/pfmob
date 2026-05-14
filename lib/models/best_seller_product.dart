import 'package:flutter/material.dart';

/// Model representing a best-selling product.
///
/// This structure mirrors the API response expected from the backend's
/// `ProductController@bestSellers` endpoint. When the real API is integrated,
/// `fromJson` will parse the server response directly.
class BestSellerProduct {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final int totalSold;
  final Color bgColor;

  const BestSellerProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.totalSold,
    required this.bgColor,
  });

  /// Factory constructor to parse JSON from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "name": "Royal Canin Kitten",
  ///   "price": 125000,
  ///   "image_url": "https://example.com/product1.jpg",
  ///   "total_sold": 150
  /// }
  /// ```
  factory BestSellerProduct.fromJson(Map<String, dynamic> json) {
    return BestSellerProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      totalSold: json['total_sold'] ?? 0,
      // Default bgColor — the API won't send this, so we generate it
      bgColor: _bgColorFromIndex(json['id'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'total_sold': totalSold,
    };
  }

  /// Generates a soft pastel background color based on product index.
  /// This keeps the visual consistency from the original hardcoded design.
  static Color _bgColorFromIndex(int id) {
    const colors = [
      Color(0xFFFFF3E8), // Warm orange
      Color(0xFFE8F5F3), // Mint green
      Color(0xFFFFE8F0), // Soft pink
      Color(0xFFE8F4FF), // Light blue
    ];
    return colors[id % colors.length];
  }
}
