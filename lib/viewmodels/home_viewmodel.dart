import '../models/product.dart';
import '../services/product_repository.dart';
import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final ProductRepository _productRepository;

  HomeViewModel({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

  List<Product> _bestSellers = const [];
  DateTime? _bestSellersLoadedAt;

  List<Product> get bestSellers => _bestSellers;
  bool get hasBestSellers => _bestSellers.isNotEmpty;

  Future<List<Product>> loadBestSellers({bool forceRefresh = false}) async {
    if (!forceRefresh && hasBestSellers && isCacheValid(_bestSellersLoadedAt)) {
      return _bestSellers;
    }

    final result = await runBusy(_productRepository.getBestSellerProducts);
    _bestSellers = result ?? const [];
    _bestSellersLoadedAt = DateTime.now();
    notifyListeners();
    return _bestSellers;
  }

  void clearCache() {
    _bestSellersLoadedAt = null;
  }
}
