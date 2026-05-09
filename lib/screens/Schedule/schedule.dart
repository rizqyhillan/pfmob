import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'reschedule.dart';

class ScheduleContent extends StatefulWidget {
  const ScheduleContent({super.key});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildTabBar(),
        const SizedBox(height: 8),
        Expanded(
          child: _selectedTab == 0
              ? _buildMendatangList(context)
              : _buildRiwayatList(context),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: AppColors.primaryLight,
            ),
            child: const ClipOval(child: Center(child: Text('🐱', style: TextStyle(fontSize: 22)))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('OWNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.2)),
              Text('Kayla Nadine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.categoryBg1,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTab('Mendatang', 0),
            _buildTab('Riwayat', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMendatangList(BuildContext context) {
    final items = [
      {
        'emoji': '🐱',
        'title': 'Premium Grooming',
        'subtitle': 'Cooper • Golden Retriever Mix',
        'date': '14 Nov 2025',
        'time': '10:30 AM',
        'status': 'CONFIRMED',
        'statusColor': const Color(0xFF4A9B8E),
      },
      {
        'emoji': '🐱',
        'title': 'Vet Consultation',
        'subtitle': 'Luna • Calico Cat',
        'date': '14 Nov 2025',
        'time': '02:15 PM',
        'status': 'PENDING',
        'statusColor': const Color(0xFFFF9800),
      },
    ];

    if (items.isEmpty) {
      return _buildKosong(
        emoji: '📅',
        judul: 'Belum Ada Jadwal',
        deskripsi: 'Kamu belum punya jadwal mendatang.\nYuk booking layanan untuk anabul kamu!',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateLabel('HARI INI, 14 NOV'),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildScheduleCard(
              context: context,
              emoji: item['emoji'] as String,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              date: item['date'] as String,
              time: item['time'] as String,
              status: item['status'] as String,
              statusColor: item['statusColor'] as Color,
              showActions: true,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRiwayatList(BuildContext context) {
    final items = [
      {
        'emoji': '🐱',
        'title': 'Premium Grooming',
        'subtitle': 'Cooper • Golden Retriever Mix',
        'date': '12 Nov 2025',
        'time': '09:30 AM',
        'status': 'SELESAI',
        'statusColor': const Color(0xFF4A9B8E),
      },
    ];

    if (items.isEmpty) {
      return _buildKosong(
        emoji: '🗂️',
        judul: 'Belum Ada Riwayat',
        deskripsi: 'Riwayat booking kamu akan\nmuncul di sini setelah selesai.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateLabel('13 NOVEMBER 2025'),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildScheduleCard(
              context: context,
              emoji: item['emoji'] as String,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              date: item['date'] as String,
              time: item['time'] as String,
              status: item['status'] as String,
              statusColor: item['statusColor'] as Color,
              showActions: false,
              showSelesai: false,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildKosong({
    required String emoji,
    required String judul,
    required String deskripsi,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              judul,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildScheduleCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required String date,
    required String time,
    required String status,
    required Color statusColor,
    required bool showActions,
    bool showSelesai = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.categoryBg1),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(time, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RescheduleScreen(
                          judulLayanan: title,
                          namaHewan: subtitle,
                          tanggalLama: date,
                          waktuLama: time,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.categoryBg1,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Reschedule',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Batalkan Booking?', style: TextStyle(fontWeight: FontWeight.w800)),
                          content: const Text('Apakah kamu yakin ingin membatalkan jadwal ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tidak', style: TextStyle(color: AppColors.textLight)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE57373),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Ya, Batalkan'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE57373)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showSelesai) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SELESAI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32), letterSpacing: 1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}