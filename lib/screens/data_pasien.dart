import 'package:flutter/material.dart';
import '../theme/tema_app.dart';
import 'ringkasan.dart';

class DataPasienScreen extends StatefulWidget {
  const DataPasienScreen({super.key});

  @override
  State<DataPasienScreen> createState() => _DataPasienScreenState();
}

class _DataPasienScreenState extends State<DataPasienScreen> {
  int _selectedHewan = 0;
  final TextEditingController _keluhanController = TextEditingController();

  final List<Map<String, String>> _hewan = [
    {'nama': 'Boy', 'jenis': 'Kucing • 2 Thn', 'emoji': '🐱'},
    {'nama': 'Luna', 'jenis': 'Anjing • 2 Thn', 'emoji': '🐶'},
  ];

  final List<String> _quickKeluhan = ['Nafsu Makan Turun', 'Lemas', 'Muntah'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgress(),
                    const SizedBox(height: 24),
                    _buildPilihHewan(),
                    const SizedBox(height: 24),
                    _buildCeritakanKeluhan(),
                  ],
                ),
              ),
            ),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Data Pasien', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Langkah 2 dari 3', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('HAMPIR SELESAI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.66,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPilihHewan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pilih Hewan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(_hewan.length, (i) {
            final selected = _selectedHewan == i;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedHewan = i),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: 2),
                          ),
                          child: Center(child: Text(_hewan[i]['emoji']!, style: const TextStyle(fontSize: 36))),
                        ),
                        if (selected)
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 22, height: 22,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_hewan[i]['nama']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text(_hewan[i]['jenis']!, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCeritakanKeluhan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ceritakan Keluhan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Jelaskan gejala atau kondisi ${_hewan[_selectedHewan]['nama']} saat ini.', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              TextField(
                controller: _keluhanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Contoh: ${_hewan[_selectedHewan]['nama']} lemas dan tidak mau makan sejak pagi tadi...',
                  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.attach_file_outlined, size: 18, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _quickKeluhan.map((k) => GestureDetector(
            onTap: () => setState(() {
              _keluhanController.text += _keluhanController.text.isEmpty ? k : ', $k';
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PembayaranDokterScreen(
          namaHewan: _hewan[_selectedHewan]['nama']!,
          keluhan: _keluhanController.text,
        ))),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Lanjut', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}