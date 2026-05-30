import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../login.dart';
import 'konfirmasi_grooming.dart';

class PaketGroomingScreen extends StatefulWidget {
  const PaketGroomingScreen({super.key});

  @override
  State<PaketGroomingScreen> createState() => _PaketGroomingScreenState();
}

class _PaketGroomingScreenState extends State<PaketGroomingScreen> {
  List<PackageType> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final packages = await ApiService.getGroomingPackages();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(String amountStr) {
    double amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _openGroomingConfirmation({
  required int idPaket,
  required String paket,
  required String harga,
  }) {
    if (!context.read<AuthViewModel>().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(redirectToProfile: false),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KonfirmasiGroomingScreen(
          idPaket: idPaket,
          namaPaket: paket,
          harga: harga,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: _packages.map((paket) {
                        bool isReguler = paket.name.toLowerCase() == 'regular';
                        bool isBasic = paket.name.toLowerCase() == 'basic';
                        
                        Color warna = isBasic ? const Color(0xFF4A9B8E) : (isReguler ? const Color(0xFF2196F3) : const Color(0xFFFF9800));
                        Color bgColor = isBasic ? const Color(0xFFE0F5F2) : (isReguler ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3E0));

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPaketCard(
                            context,
                            idPaket: paket.id,
                            paket: paket.label,
                            harga: _formatCurrency(paket.hargaPerMalam),
                            deskripsi: paket.description,
                            fasilitas: paket.fasilitas,
                            warna: warna,
                            bgColor: bgColor,
                            isFavorit: isReguler,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Paket Grooming',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih paket yang sesuai untuk anabul kamu',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaketCard(
    BuildContext context, {
    required int idPaket,
    required String paket,
    required String harga,
    required String deskripsi,
    required List<String> fasilitas,
    required Color warna,
    required Color bgColor,
    bool isFavorit = false,
  }) {
    return GestureDetector(
      onTap: () => _openGroomingConfirmation(
        idPaket: idPaket,
        paket: paket,
        harga: harga,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isFavorit ? warna : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Paket $paket',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: warna),
                            ),
                            if (isFavorit) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: warna,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(deskripsi, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
                Text(
                  harga,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: warna),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            ...fasilitas.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: warna, size: 16),
                  const SizedBox(width: 8),
                  Text(f, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                ],
              ),
            )),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Pilih Paket $paket',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}