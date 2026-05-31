import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../viewmodels/pet_viewmodel.dart';
import '../../theme/tema_app.dart';
import '../../widgets/user_avatar.dart';
import 'detail_pet.dart';
import 'profile.dart';
import 'tambah_hewan.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Kucing', 'Anjing', 'Kelinci'];

  late Future<List<Pet>> _futurePets;

  @override
  void initState() {
    super.initState();
    _futurePets = context.read<PetViewModel>().loadPets();
  }

  void _refreshPets() {
    setState(() {
      _futurePets = context.read<PetViewModel>().loadPets();
    });
  }

  List<Pet> _applyFilter(List<Pet> pets) {
    if (_selectedFilter == 0) return pets;

    final filter = _filters[_selectedFilter].toLowerCase();

    return pets.where((pet) {
      return pet.jenis.toLowerCase() == filter;
    }).toList();
  }

  Color _getPetColor(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'anjing':
        return const Color(0xFFFFF3E0);
      case 'kucing':
        return const Color(0xFFE8F5F3);
      case 'kelinci':
        return const Color(0xFFEDE7F6);
      default:
        return AppColors.categoryBg1;
    }
  }

  String _getPetImage(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'anjing':
        return 'assets/images/buddy.jpg';
      case 'kucing':
        return 'assets/images/mittens.jpg';
      case 'kelinci':
        return 'assets/images/charlie.jpg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterBar(),
            Expanded(
              child: FutureBuilder<List<Pet>>(
                future: _futurePets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  final pets = _applyFilter(snapshot.data ?? []);

                  if (pets.isEmpty) {
                    return _buildKosong();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refreshPets(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: pets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final pet = pets[i];
                        final warna = _getPetColor(pet.jenis);
                        final foto = pet.foto.isNotEmpty ? pet.foto : _getPetImage(pet.jenis);

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPetScreen(
                                id: pet.id,
                                nama: pet.nama,
                                jenis: pet.jenis,
                                ras: pet.ras,
                                umur: pet.umur,
                                kelamin: pet.jenisKelamin,
                                foto: foto,
                                warna: warna,
                                tentang: pet.catatan,
                              ),
                            ),
                          ).then((_) => _refreshPets()),
                          child: _buildPetCard(pet, warna, foto),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahHewanScreen()),
        ).then((_) => _refreshPets()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Pets',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Hewan peliharaan yang terdaftar',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
            ],
          ),
          const Spacer(),
          UserAvatar(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(showBackButton: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final selected = _selectedFilter == i;

            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet, Color warna, String foto) {
    return Container(
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: foto.isEmpty
                  ? Container(
                      color: Colors.white,
                      child: const Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    )
                  : foto.startsWith('http')
                      ? Image.network(
                          foto,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.white,
                            child: const Icon(
                              Icons.pets,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                        )
                      : Image.asset(
                          foto,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.white,
                            child: const Icon(
                              Icons.pets,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                        ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pet.ras,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBadge(pet.jenis),
                    const SizedBox(width: 8),
                    _buildBadge(pet.umur),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.isEmpty ? '-' : label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.categoryBg1,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Image(
                  image: AssetImage('assets/images/logo-paw.png'),
                  width: 42,
                  height: 42,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Hewan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan hewan peliharaanmu\ndengan menekan tombol + di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data hewan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPets,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}