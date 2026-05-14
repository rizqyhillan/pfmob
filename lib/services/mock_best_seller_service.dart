import 'package:flutter/material.dart';
import '../models/best_seller_product.dart';
import 'best_seller_service.dart';

/// Mock implementation of [BestSellerService].
///
/// Returns hardcoded product data with a simulated network delay.
/// This will be replaced by [ApiBestSellerService] once the backend
/// endpoint `GET /api/products/best-sellers` is ready.
class MockBestSellerService implements BestSellerService {
  /// Simulated network delay duration.
  final Duration _delay;

  /// If true, simulates a network error for testing error states.
  final bool simulateError;

  /// If true, returns an empty list for testing empty states.
  final bool simulateEmpty;

  MockBestSellerService({
    Duration? delay,
    this.simulateError = false,
    this.simulateEmpty = false,
  }) : _delay = delay ?? const Duration(milliseconds: 800);

  @override
  Future<List<BestSellerProduct>> getBestSellers() async {
    // Simulate network latency
    await Future.delayed(_delay);

    // Simulate error state for testing
    if (simulateError) {
      throw Exception('Gagal memuat data produk best seller.');
    }

    // Simulate empty state for testing
    if (simulateEmpty) {
      return [];
    }

    // Mock data matching the original hardcoded list and future API structure
    return const [
      BestSellerProduct(
        id: 1,
        name: 'Royal Canin\nKitten',
        price: 125000,
        imageUrl: 'assets/images/product1.jpg',
        totalSold: 152,
        bgColor: Color(0xFFFFF3E8),
      ),
      BestSellerProduct(
        id: 2,
        name: 'Me-O Creamy\nTreats',
        price: 35000,
        imageUrl: 'assets/images/product2.jpg',
        totalSold: 98,
        bgColor: Color(0xFFE8F5F3),
      ),
      BestSellerProduct(
        id: 3,
        name: 'Cat\nShampoo',
        price: 45000,
        imageUrl: 'assets/images/product3.jpg',
        totalSold: 74,
        bgColor: Color(0xFFFFE8F0),
      ),
      BestSellerProduct(
        id: 4,
        name: 'Salmon\nPowder',
        price: 89000,
        imageUrl: 'assets/images/product4.jpg',
        totalSold: 63,
        bgColor: Color(0xFFE8F4FF),
      ),
    ];
  }
}
