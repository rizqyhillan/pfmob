import '../models/models.dart';
import '../services/api_service.dart';
import '../services/product_repository.dart';
import 'base_viewmodel.dart';

class ShopViewModel extends BaseViewModel {
  final ProductRepository _productRepository;

  ShopViewModel({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

  List<String> _categories = const ['Semua'];
  List<Product> _products = const [];
  Product? _selectedProduct;
  ShopCart? _cart;

  List<String> get categories => _categories;
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  ShopCart? get cart => _cart;
  int get cartItemCount => _cart?.totalItem ?? 0;
  bool get hasCartItems => (_cart?.items.isNotEmpty ?? false);

  Future<void> loadProducts({String search = '', String selectedCategory = 'Semua'}) async {
    await runBusy(() async {
      final results = await Future.wait([
        ApiService.getShopCategories(),
        _productRepository.getProducts(
          search: search,
          kategori: selectedCategory == 'Semua' ? null : selectedCategory,
        ),
      ]);
      _categories = ['Semua', ...(results[0] as List<String>)];
      _products = results[1] as List<Product>;
    });
    notifyListeners();
  }

  Future<Product?> loadProductDetail(int productId) async {
    final product = await runBusy(() => _productRepository.getProductDetail(productId));
    _selectedProduct = product;
    notifyListeners();
    return product;
  }

  Future<ShopCart?> loadCart({bool silent = false}) async {
    if (!silent) setLoading(true);
    clearError();
    try {
      _cart = await ApiService.getCart();
      return _cart;
    } catch (e) {
      if (!silent) setError(e);
      _cart = null;
      return null;
    } finally {
      if (!silent) setLoading(false);
      notifyListeners();
    }
  }

  Future<ShopCart?> addToCart({required int productId, required int quantity, int? variationId}) async {
    final result = await runBusy(() => ApiService.addCartItem(
          idBarang: productId,
          jumlah: quantity,
          idVariasi: variationId,
        ));
    if (result != null) _cart = result;
    notifyListeners();
    return result;
  }

  Future<ShopCart?> updateCartItem({required int itemId, required int quantity}) async {
    final result = await runBusy(() => ApiService.updateCartItem(itemId: itemId, jumlah: quantity));
    if (result != null) _cart = result;
    notifyListeners();
    return result;
  }

  Future<ShopCart?> removeCartItem(int itemId) async {
    final result = await runBusy(() => ApiService.removeCartItem(itemId));
    if (result != null) _cart = result;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>?> checkoutCart({String? note, String paymentMethod = 'ewallet'}) async {
    final result = await runBusy(() => ApiService.checkoutCart(catatan: note, metodeBayar: paymentMethod));
    if (result != null) {
      await loadCart(silent: true);
    }
    return result;
  }
}
