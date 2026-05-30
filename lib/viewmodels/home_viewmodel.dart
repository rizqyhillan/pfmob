import '../models/product.dart';
import '../services/product_repository.dart';
import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final ProductRepository _productRepository;

  HomeViewModel({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

  List<Product> _bestSellers = const [];
  List<Product> get bestSellers => _bestSellers;

  Future<List<Product>> loadBestSellers() async {
    final result = await runBusy(_productRepository.getBestSellerProducts);
    _bestSellers = result ?? const [];
    notifyListeners();
    return _bestSellers;
  }
}
