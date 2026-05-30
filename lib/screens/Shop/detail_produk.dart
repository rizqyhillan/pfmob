import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../login.dart';
import '../../models/product.dart';
import '../../services/product_repository.dart';

class DetailProdukScreen extends StatefulWidget {
  final int? productId;

  // Parameter lama tetap dibuat optional supaya caller lama seperti dashboard tidak error compile.
  final String? nama;
  final double? harga;
  final String? image;
  final Color? bgColor;
  final List<String> pilihanjenis;
  final String? deskripsi;

  const DetailProdukScreen({
    super.key,
    this.productId,
    this.nama,
    this.harga,
    this.image,
    this.bgColor,
    this.pilihanjenis = const [],
    this.deskripsi,
  });

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  Product? _product;
  int _jumlah = 1;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  ProductVariation? _selectedVariation;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _loadProduct() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.productId == null) {
      setState(() {
        _product = Product(
          id: 0,
          name: widget.nama ?? '-',
          category: 'Best Seller',
          price: widget.harga ?? 0,
          stock: 0,
          imageUrl: widget.image ?? '',
          tersedia: false,
          isFeatured: false,
          totalSold: 0,
          bgColor: Colors.white,
          variations: [],
        );
        _loading = false;
      });
      return;
    }

    try {
      final product = await ProductRepository().getProductDetail(widget.productId!);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    final product = _product;
  
    if (product == null || product.id == 0 || _saving) return;

    if (product.variations.isNotEmpty && _selectedVariation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih variasi produk terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  
    if (!context.read<AuthViewModel>().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(redirectToProfile: false),
        ),
      );
      return;
    }
  
    setState(() => _saving = true);
  
    try {
      await ApiService.addCartItem(
        idBarang: product.id,
        jumlah: _jumlah,
        idVariasi: _selectedVariation?.id,
      );
  
      if (!mounted) return;
  
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImage(product!),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                                    const SizedBox(height: 8),
                                    Text(product.category, style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 14),
                                    Text('Rp ${_formatHarga(_selectedVariation?.harga ?? product.price)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                                    const SizedBox(height: 8),
                                    Text('Stok tersedia: ${_selectedVariation?.stok ?? product.stock}', style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                                    const SizedBox(height: 24),
                                    _buildVariations(product),
                                    _buildJumlah(_selectedVariation?.stok ?? product.stock),
                                    const SizedBox(height: 18),
                                    _infoBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildBottom(product),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadProduct, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );

  Widget _buildImage(Product product) {
    final hasImages = product.imageUrls.isNotEmpty;
    return Stack(
      children: [
        Container(
          height: 310,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.categoryBg1,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: hasImages
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: product.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = product.imageUrls[index];
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Image(
                            image: AssetImage('assets/images/logo-paw.png'),
                            width: 88,
                            height: 88,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Image(
                    image: AssetImage('assets/images/logo-paw.png'),
                    width: 88,
                    height: 88,
                  ),
                ),
        ),
        if (hasImages && product.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.imageUrls.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariations(Product product) {
    if (product.variations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Variasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: product.variations.map((v) {
            final isSelected = _selectedVariation?.id == v.id;
            final isOutOfStock = v.stok <= 0;

            return GestureDetector(
              onTap: isOutOfStock
                  ? null
                  : () {
                      setState(() {
                        _selectedVariation = isSelected ? null : v;
                        if (_selectedVariation != null && _jumlah > _selectedVariation!.stok) {
                          _jumlah = _selectedVariation!.stok;
                        } else if (_selectedVariation == null && _jumlah > product.stock) {
                          _jumlah = product.stock > 0 ? product.stock : 1;
                        }
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isOutOfStock ? AppColors.divider.withValues(alpha: 0.5) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isOutOfStock ? AppColors.divider.withValues(alpha: 0.3) : AppColors.divider),
                    width: 1.5,
                  ),
                ),
                child: Opacity(
                  opacity: isOutOfStock ? 0.5 : 1.0,
                  child: Text(
                    '${v.namaVariasi} (${isOutOfStock ? "Habis" : "Stok: ${v.stok}"})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isOutOfStock ? AppColors.textLight : AppColors.textDark),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildJumlah(int stok) {
    return Row(
      children: [
        const Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const Spacer(),
        IconButton(
          onPressed: _jumlah > 1 ? () => setState(() => _jumlah--) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$_jumlah', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        IconButton(
          onPressed: _jumlah < stok ? () => setState(() => _jumlah++) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _infoBox() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(16)),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: AppColors.accent),
            SizedBox(width: 10),
            Expanded(child: Text('Checkout akan membuat transaksi shopping berstatus pending. Integrasi payment gateway bisa dilanjutkan oleh tim payment nanti.', style: TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.45))),
          ],
        ),
      );

  Widget _buildBottom(Product product) {
    final isOutOfStock = product.variations.isNotEmpty 
        ? (_selectedVariation != null && _selectedVariation!.stok <= 0)
        : product.stock <= 0;
    
    final canAddToCart = product.id != 0 && !isOutOfStock && !_saving;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canAddToCart ? _addToCart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          child: Text(
            product.id == 0
                ? 'Buka tab Shop untuk checkout'
                : (isOutOfStock
                    ? 'Stok Habis'
                    : (_saving ? 'Menambahkan...' : 'Tambah ke Keranjang')),
          ),
        ),
      ),
    );
  }
}
