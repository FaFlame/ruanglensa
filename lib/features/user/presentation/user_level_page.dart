import 'package:flutter/material.dart';

class UserLevelPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserLevelPage({super.key, required this.userData});

  String _getLevelName(int points) {
    if (points <= 1000) return 'Level 1 - Biasa';
    if (points <= 2000) return 'Level 2 - Langganan';
    return 'Level 3 - Premium';
  }

  int _getLevelMax(int points) {
    if (points <= 1000) return 1000;
    if (points <= 2000) return 2000;
    return 3000;
  }

  int _getLevelMin(int points) {
    if (points <= 1000) return 0;
    if (points <= 2000) return 1001;
    return 2001;
  }

  List<String> _getLevelBenefits(int points) {
    if (points <= 1000) {
      return ['Akses semua produk sewa', 'Histori pesanan', 'Dukungan standar'];
    }
    if (points <= 2000) {
      return [
        'Pelayanan ditingkatkan',
        'Diskon biaya sewa',
        'Undang teman dengan kode referral',
        'Dukungan beberapa aksesori kamera tanpa biaya',
      ];
    }
    return [
      'Semua keuntungan Langganan',
      'Prioritas layanan',
      'Diskon lebih besar',
      'Aksesori kamera gratis pilihan',
      'Early access produk baru',
    ];
  }

  IconData _getBenefitIcon(int index, int points) {
    if (points <= 1000) {
      const icons = [
        Icons.photo_camera_outlined,
        Icons.history_rounded,
        Icons.support_agent_outlined,
      ];
      return icons[index % icons.length];
    }
    if (points <= 2000) {
      const icons = [
        Icons.bolt_outlined,
        Icons.monetization_on_outlined,
        Icons.people_outline,
        Icons.camera_outlined,
      ];
      return icons[index % icons.length];
    }
    const icons = [
      Icons.star_border_rounded,
      Icons.rocket_launch_outlined,
      Icons.discount_outlined,
      Icons.camera_outlined,
      Icons.new_releases_outlined,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final levelPoints =
        int.tryParse((userData['level_points'] ?? 0).toString()) ?? 0;
    final levelName = _getLevelName(levelPoints);
    final levelMax = _getLevelMax(levelPoints);
    final levelMin = _getLevelMin(levelPoints);
    final progress = (levelPoints - levelMin) / (levelMax - levelMin);
    final benefits = _getLevelBenefits(levelPoints);

    // Kode referral dari UID 10 karakter pertama
    // Referral dari username, fallback ke email depan @ , fallback ke '----'
    final String rawRef = (userData['username'] as String? ?? '').isNotEmpty
        ? (userData['username'] as String)
        : (userData['email'] as String? ?? '').split('@').first;
    final String referralCode = rawRef.isNotEmpty
        ? rawRef
              .substring(0, rawRef.length >= 10 ? 10 : rawRef.length)
              .toUpperCase()
        : '----------';

    // Hitung estimasi hemat
    final int hemat = levelPoints * 50;
    final String hematFormatted =
        'Rp. ${hemat.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} dari pesanan Anda.';
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Level Saya',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Level + progress bar ──
            Text(
              levelName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF021427),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$levelPoints/$levelMax',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // ── Keuntungan Saya ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keuntungan Saya',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(benefits.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(
                            _getBenefitIcon(i, levelPoints),
                            size: 18,
                            color: const Color(0xFF021427),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefits[i],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Kode Referral ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kode Referral Anda',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    referralCode,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Anda Hemat ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anda hemat',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hematFormatted,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
