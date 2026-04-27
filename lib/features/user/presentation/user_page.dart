import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;

  void _onNavTap(int idx) {
    setState(() => _selectedIndex = idx);
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
          child: Icon(icon, size: 28, color: const Color(0xFF021427)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _productCard(String assetName, String title, String price) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(assetName),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // top spacing and logo row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [Image.asset('assets/images/logo.png', width: 120)],
              ),
            ),

            // Main scrollable content between logo and nav
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carousel image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/carousel.png',
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Cari penyewaan foto & video',
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
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF021427),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Cari',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Categories
                    const Text(
                      'Kategori',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategory('Kamera', Icons.photo_camera_outlined),
                        _buildCategory('Lensa', Icons.circle_outlined),
                        _buildCategory('Paket', Icons.inbox_outlined),
                        _buildCategory('Semua', Icons.grid_view_outlined),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Sample horizontal product list
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Penawaran Terbaik',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _productCard(
                            'assets/images/produk1.png',
                            'Sony A6400',
                            'Rp. 429.000/7 hari',
                          ),
                          const SizedBox(width: 12),
                          _productCard(
                            'assets/images/produk2.png',
                            'Nikon D3400',
                            'Rp. 126.000/7 hari',
                          ),
                          const SizedBox(width: 12),
                          _productCard(
                            'assets/images/produk3.png',
                            'Paket Liburan',
                            'Rp. 429.000/paket',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    // Paket Jasa section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paket Jasa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: List.generate(
                        6,
                        (i) => Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/produk${(i % 3) + 1}.png',
                                width: double.infinity,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Paket Liburan',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Rp. 429.000/paket',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom navigation bar overlay point (nav sits above bottom)
            Container(height: 8, color: Colors.transparent),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Status Sewa',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pengguna'),
        ],
      ),
    );
  }
}
