import 'package:flutter/material.dart';
import 'dart:ui';

// Ganti import ini sesuai path page asli di project kamu
// import 'status_sewa_page.dart';
// import 'pengguna_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;

  // Ganti _PlaceholderPage(...) dengan page asli kamu
  late final List<Widget> _pages = [
    const _HomePage(),
    const _PlaceholderPage('Status Sewa'),  // ganti: StatusSewaPage()
    const _PlaceholderPage('Pengguna'),     // ganti: PenggunaPage()
  ];

  static const List<String> _pageTitles = [
    '',
    'Status Sewa',
    'Pengguna',
  ];

  void _onNavTap(int idx) {
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [
          // ── Konten utama ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + judul halaman aktif
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo.png', width: 120),
                      if (_pageTitles[_selectedIndex].isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _pageTitles[_selectedIndex],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Halaman aktif
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),

          // ── Floating bottom nav — pinned ke bawah layar, tengah ──────
          Positioned(
            bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: 370,
                    height: 69,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (i) {
                        final isActive = i == _selectedIndex;
                        const items = [
                          _NavItem(
                              icon: Icons.home_rounded, label: 'Beranda'),
                          _NavItem(
                              icon: Icons.calendar_today_rounded,
                              label: 'Status Sewa'),
                          _NavItem(
                              icon: Icons.person_rounded,
                              label: 'Pengguna'),
                        ];
                        final item = items[i];

                        return GestureDetector(
                          onTap: () => _onNavTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: isActive
                                ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                  )
                                : null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isActive
                                      ? const Color(0xFF1C1C1E)
                                      : Colors.white,
                                ),
                                if (isActive) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// Halaman Beranda
// ─────────────────────────────────────────────────────────────────────────────
class _HomePage extends StatelessWidget {
  const _HomePage();

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Row(
          children: const [
            Text('Lihat Semua',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            Icon(Icons.chevron_right, size: 18, color: Colors.black54),
          ],
        ),
      ],
    );
  }

  Widget _buildCategory(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, size: 26, color: const Color(0xFF021427)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Satu widget card seragam untuk semua section produk
  Widget _produkCard(String assetName, String name, String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(assetName,
              width: double.infinity, height: 88, fit: BoxFit.cover),
        ),
        const SizedBox(height: 6),
        Text(name,
            style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(price,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding bawah agar konten tidak tertutup floating nav
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carousel ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/carousel.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Cari penyewaan foto & video',
                              hintStyle: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF021427),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Cari',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Kategori ──────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Kategori',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategory('Kamera', Icons.photo_camera_outlined),
                _buildCategory('Lensa', Icons.circle_outlined),
                _buildCategory('Paket', Icons.inbox_outlined),
                _buildCategory('Semua', Icons.grid_view_outlined),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Penawaran Terbaik ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionHeader('Penawaran Terbaik'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              children: [
                _produkCard('assets/images/produk1.png',
                    'Sony A6400', 'Rp. 429.000/7 hari'),
                _produkCard('assets/images/produk2.png',
                    'Nikon D3400', 'Rp. 126.000/7 hari'),
                _produkCard('assets/images/produk3.png',
                    'Paket Liburan', 'Rp. 429.000/paket'),
                _produkCard('assets/images/produk4.png',
                    'Konten Kreator', 'Rp. 429.000/paket'),
                _produkCard('assets/images/produk5.png',
                    'Lumix 0.25mm', 'Rp. 126.000/7 hari'),
                _produkCard('assets/images/produk6.png',
                    'Samsung NX1', 'Rp. 100.000/7 hari'),
                _produkCard('assets/images/produk7.png',
                    'Fujifilm X-T10', 'Rp. 143.000/7 hari'),
                _produkCard('assets/images/produk8.png',
                    'Paket Travelling', 'Rp. 126.000/paket'),
                _produkCard('assets/images/produk9.png',
                    'Canon 28-70mm', 'Rp. 429.000/7 hari'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Paket Jasa ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionHeader('Paket Jasa'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              children: [
                _produkCard('assets/images/paket1.png',
                    'Paket Travelling', 'Rp. 126.000/paket'),
                _produkCard('assets/images/paket2.png',
                    'Paket Pernikahan', 'Rp. 143.000/paket'),
                _produkCard('assets/images/paket3.png',
                    'Konten Kreator', 'Rp. 429.000/paket'),
                _produkCard('assets/images/paket4.png',
                    'Paket Wisuda', 'Rp. 126.000/paket'),
                _produkCard('assets/images/paket5.png',
                    'Event Besar', 'Rp. 999.000/paket'),
                _produkCard('assets/images/paket6.png',
                    'Paket Liburan', 'Rp. 429.000/paket'),
                _produkCard('assets/images/paket4.png',
                    'Paket Wisuda', 'Rp. 126.000/paket'),
                _produkCard('assets/images/paket5.png',
                    'Event Besar', 'Rp. 999.000/paket'),
                _produkCard('assets/images/paket6.png',
                    'Paket Liburan', 'Rp. 429.000/paket'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Kamera ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionHeader('Kamera'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              children: [
                _produkCard('assets/images/kamera1.png',
                    'Canon EOS 600D', 'Rp. 329/7 days'),
                _produkCard('assets/images/kamera2.png',
                    'Nikon D3400', 'Rp. 126.000/7 days'),
                _produkCard('assets/images/kamera3.png',
                    'Fujifilm X-T10', 'Rp. 143.000/7 days'),
                _produkCard('assets/images/kamera4.png',
                    'Sony A9', 'Rp. 429.000/7 days'),
                _produkCard('assets/images/kamera5.png',
                    'Lumix G7', 'Rp. 126.000/7 days'),
                _produkCard('assets/images/kamera6.png',
                    'Nikon D5600', 'Rp. 143.000/7 days'),
                  _produkCard('assets/images/kamera4.png',
                    'Sony A9', 'Rp. 429.000/7 days'),
                _produkCard('assets/images/kamera5.png',
                    'Lumix G7', 'Rp. 126.000/7 days'),
                _produkCard('assets/images/kamera6.png',
                    'Nikon D5600', 'Rp. 143.000/7 days'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Lensa ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionHeader('Lensa'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              children: [
                _produkCard('assets/images/lensa1.png',
                    'Canon EF 24-105mm', 'Rp. 429.000/7 days'),
                _produkCard('assets/images/lensa2.png',
                    'Lumix S 100mm', 'Rp. 126.000/7 days'),
                _produkCard('assets/images/lensa3.png',
                    'Sony FE 24-70mm', 'Rp. 143.000/7 days'),
                _produkCard('assets/images/lensa4.png',
                    'Canon 28-70mm', 'Rp. 429.000/7 days'),
                _produkCard('assets/images/lensa5.png',
                    'Lumix 0.25mm', 'Rp. 126.000/7 days'),
                _produkCard('assets/images/lensa6.png',
                    'Sony APS-C Lenses', 'Rp. 143.000/7 days'),
                 _produkCard('assets/images/lensa4.png',
                    'Canon 28-70mm', 'Rp. 429.000/7 days'),
                _produkCard('assets/images/lensa5.png',
                    'Lumix 0.25mm', 'Rp. 126.000/7 days'),
                _produkCard('assets/images/lensa6.png',
                    'Sony APS-C Lenses', 'Rp. 143.000/7 days'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder — ganti dengan page asli kamu
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman $title',
        style: const TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}