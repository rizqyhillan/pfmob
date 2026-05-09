import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'profile.dart';
import '../profile/detail_pet.dart';
import '../profile/tambah_hewan.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Kucing', 'Anjing', 'Kelinci'];

  final List<_Pet> _pets = [
    _Pet(
      nama: 'Buddy',
      jenis: 'Anjing',
      ras: 'Golden Retriever',
      umur: '2 tahun',
      kelamin: 'Jantan',
      foto: 'assets/images/buddy.jpg', 
      warna: Color(0xFFFFF3E0),
    ),
    _Pet(
      nama: 'Mittens',
      jenis: 'Kucing',
      ras: 'Persian Cat',
      umur: '1 tahun',
      kelamin: 'Betina',
      foto: 'assets/images/mittens.jpg',
      warna: Color(0xFFE8F5F3),
    ),
    _Pet(
      nama: 'Charlie',
      jenis: 'Kelinci',
      ras: 'Holland Lop',
      umur: '8 bulan',
      kelamin: 'Jantan',
      foto: 'assets/images/charlie.jpg', 
      warna: Color(0xFFEDE7F6),
    ),
  ];

  List<_Pet> get _filtered {
    if (_selectedFilter == 0) return _pets;
    final filter = _filters[_selectedFilter];
    return _pets.where((p) => p.jenis == filter).toList();
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
              child: _filtered.isEmpty
                  ? _buildKosong()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPetScreen(
                              nama: _filtered[i].nama,
                              jenis: _filtered[i].jenis,
                              ras: _filtered[i].ras,
                              umur: _filtered[i].umur,
                              kelamin: _filtered[i].kelamin,
                              foto: _filtered[i].foto,
                              warna: _filtered[i].warna,
                            ),
                          ),
                        ),
                        child: _buildPetCard(_filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahHewanScreen()),
        ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Pets',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
              ),
              Text(
                'Hewan peliharaan yang terdaftar',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: AppColors.primaryLight,
              ),
              child: const ClipOval(
                child:
                    Center(child: Text('🐱', style: TextStyle(fontSize: 22))),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          selected ? AppColors.primary : AppColors.divider),
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

  Widget _buildPetCard(_Pet pet) {
    return Container(
      decoration: BoxDecoration(
        color: pet.warna,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Foto hewan
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08), blurRadius: 8)
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                pet.foto,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                // Fallback kalau foto belum ada
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white,
                  child: const Icon(Icons.pets,
                      color: AppColors.primary, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info hewan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pet.nama,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets,
                          color: AppColors.primary, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pet.ras,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBadge(pet.kelamin),
                    const SizedBox(width: 8),
                    _buildBadge(pet.umur)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
      )
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
              decoration: BoxDecoration(
                  color: AppColors.categoryBg1, shape: BoxShape.circle),
              child: const Center(
                  child: Text('🐾', style: TextStyle(fontSize: 42))),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Hewan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan hewan peliharaanmu\ndengan menekan tombol + di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textLight, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pet {
  final String nama;
  final String jenis;
  final String ras;
  final String umur;
  final String kelamin;
  final String foto;
  final Color warna;

  const _Pet({
    required this.nama,
    required this.jenis,
    required this.ras,
    required this.umur,
    required this.kelamin,
    required this.foto,
    required this.warna,
  });
}