import '../models/best_seller_product.dart';

/// Abstract interface for the Best Seller data source.
///
/// This abstraction allows swapping the mock implementation with a real
/// API-backed implementation without changing any UI code.
///
/// To switch to a real API:
/// 1. Create `ApiBestSellerService implements BestSellerService`
/// 2. Call the backend endpoint `GET /api/products/best-sellers`
/// 3. Parse the response using `BestSellerProduct.fromJson`
/// 4. Replace `MockBestSellerService()` with `ApiBestSellerService()` in dashboard.dart
abstract class BestSellerService {
  /// Fetches the list of best-selling products.
  ///
  /// Returns a [Future] that resolves to a list of [BestSellerProduct].
  /// Throws an [Exception] if the data cannot be loaded.
  Future<List<BestSellerProduct>> getBestSellers();
}
