// lib/pages/user_page.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ruanglensa/features/user/presentation/profile_page.dart';
import 'package:ruanglensa/features/user/presentation/search_page.dart';
import 'package:ruanglensa/features/user/presentation/kategori_page.dart';
import 'package:ruanglensa/features/user/presentation/detail_produk_page.dart';
import 'dart:ui';

import 'produk_model.dart';
import 'produk_service.dart';

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

   late final List<Widget> _pages = [
    const _HomePage(),
    const _PlaceholderPage('Status Sewa'), // ganti: StatusSewaPage()
    const ProfilePage(), // ganti: PenggunaPage()
  ];

  static const List<String> _pageTitles = [
    '', //beranda
     '', //status sewa
      '' //pengguna
      ];

  void _onNavTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo + judul halaman ──────────────────────────────
                if (_selectedIndex == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Image.asset('assets/images/logo.png', width: 120),
                  ),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
              ],
            ),
          ),

          // ── Floating bottom nav ───────────────────────────────────────
          Positioned(
            bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: 370,
                    height: 69,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (i) {
                        final isActive = i == _selectedIndex;
                        const items = [
                          _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
                          _NavItem(icon: Icons.calendar_today_rounded, label: 'Status Sewa'),
                          _NavItem(icon: Icons.person_rounded, label: 'Pengguna'),
                        ];
                        final item = items[i];
                        return GestureDetector(
                          onTap: () => _onNavTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 8),
                            decoration: isActive
                                ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                : null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.icon, size: 22,
                                    color: isActive
                                        ? const Color(0xFF1C1C1E)
                                        : Colors.white),
                                if (isActive) ...[
                                  const SizedBox(height: 3),
                                  Text(item.label,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1C1C1E))),
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
// Halaman Beranda — semua produk diambil dari ProdukService
// ─────────────────────────────────────────────────────────────────────────────
class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _service = ProdukService.instance;

  late Future<List<Produk>> _penawaranFuture;
  late Future<List<Paket>>  _paketJasaFuture;
  late Future<List<Produk>> _kameraFuture;
  late Future<List<Produk>> _lensaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _penawaranFuture = _service.fetchPenawaranTerbaik();
    _paketJasaFuture = _service.fetchPaketJasa();
    _kameraFuture    = _service.fetchKamera();
    _lensaFuture     = _service.fetchLensa();
  }

  // Tarik-untuk-refresh
  Future<void> _onRefresh() async {
    setState(() => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Carousel ────────────────────────────────────────────────
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

   // ── Search bar ──────────────────────────────────────────────
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    height: 44,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        // Search bar
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cari penyewaan foto & video',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tombol Cari
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: const Color(0xFF021427),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Cari',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  ),
                 ),
               ),
             ),
           ),
         ],
       ),
     ),
   ),
            const SizedBox(height: 20),

            // ── Kategori ────────────────────────────────────────────────
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
                  _buildCategory('Kamera', 'assets/images/kategorilogokamera.png'),
                  _buildCategory('Lensa', 'assets/images/kategorilogolensa.png'),
                  _buildCategory('Paket', 'assets/images/kategorilogopaket.png'),
                  _buildCategory('Semua', 'assets/images/kategorilogosemua.png'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Penawaran Terbaik ────────────────────────────────────────
            _sectionWithGrid(
              title: 'Penawaran Terbaik',
              future: _penawaranFuture,
            ),

            // ── Paket Jasa ───────────────────────────────────────────────
            _sectionWithPaketGrid(
              title: 'Paket Jasa',
              future: _paketJasaFuture,
            ),

            // ── Kamera ───────────────────────────────────────────────────
            _sectionWithGrid(
              title: 'Kamera',
              future: _kameraFuture,
            ),

            // ── Lensa ────────────────────────────────────────────────────
            _sectionWithGrid(
              title: 'Lensa',
              future: _lensaFuture,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Section Paket Jasa (pakai model Paket) ───────────────────────────────
  Widget _sectionWithPaketGrid({
    required String title,
    required Future<List<Paket>> future,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sectionHeader(title),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Paket>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildGridSkeleton();
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Gagal memuat data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            final paketList = snapshot.data ?? [];
            if (paketList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Belum ada paket.',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
                children: paketList.map((p) => _PaketCard(paket: p)).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  // ── Section grid untuk Produk (Penawaran, Kamera, Lensa) ─────────────────
  Widget _sectionWithGrid({
    required String title,
    required Future<List<Produk>> future,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sectionHeader(title),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Produk>>(
          future: future,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildGridSkeleton();
            }
            // Error state
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Gagal memuat data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            // Data kosong
            final produkList = snapshot.data ?? [];
            if (produkList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Belum ada produk.',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            // Grid produk
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
                children: produkList
                    .map((p) => _ProdukCard(produk: p))
                    .toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  // Skeleton loading 6 kotak abu-abu saat data belum datang
  Widget _buildGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
        children: List.generate(6, (_) => _SkeletonCard()),
      ),
    );
  }

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

  Widget _buildCategory(String label, String imageAsset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryPage(
              categoryName: label,
              categoryImage: imageAsset,
            ),
          ),
        );
      },
      child: Container(
        width: 95,
        height: 96,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child:
              Image.asset(
                imageAsset,
                width: 38,
                height: 38,
                fit: BoxFit.contain),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card untuk koleksi "produk" (Kamera & Lensa)
// ─────────────────────────────────────────────────────────────────────────────
class _ProdukCard extends StatelessWidget {
  final Produk produk;
  const _ProdukCard({required this.produk});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (produk.gambarProduk.isNotEmpty) {
      imageBytes = base64Decode(produk.gambarProduk);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>DetailProdukPage(produkId: produk.id),
    ),
  ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(height: 6),
        Text(
          produk.namaProduk,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          produk.hargaFormatted,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: double.infinity,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 28),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Card untuk koleksi "paket" (Paket Jasa)
// ─────────────────────────────────────────────────────────────────────────────
class _PaketCard extends StatelessWidget {
  final Paket paket;
  const _PaketCard({required this.paket});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (paket.gambarPaket.isNotEmpty) {
      imageBytes = base64Decode(paket.gambarPaket);
    }

   return GestureDetector(
    onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>DetailProdukPage(produkId: paket.id),
    ),
  ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(height: 6),
        Text(
          paket.namaPaket,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          paket.hargaFormatted,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: double.infinity,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 28),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton card saat loading
// ─────────────────────────────────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 10, width: 80, color: Colors.grey.shade200),
        const SizedBox(height: 4),
        Container(height: 8, width: 60, color: Colors.grey.shade200),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder page
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman $title',
          style: const TextStyle(fontSize: 18, color: Colors.black54)),
    );
  }
}