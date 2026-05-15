// lib/pages/admin/admin_home_page.dart

import 'package:flutter/material.dart';
import 'admin_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Future<Map<String, dynamic>> _statistikFuture;

  @override
  void initState() {
    super.initState();
    _statistikFuture = AdminService.instance.fetchStatistik();
  }

  String _formatRupiah(int angka) {
    final str = angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $str';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _statistikFuture = AdminService.instance.fetchStatistik();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────
              const Text('Selamat Datang, Admin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Laporan',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 16),

              FutureBuilder<Map<String, dynamic>>(
                future: _statistikFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red));
                  }

                  final data      = snapshot.data!;
                  final revenue   = data['totalRevenue'] as int;
                  final order     = data['totalOrder'] as int;
                  final customers = data['totalCustomers'] as int;
                  final produk    = data['totalProduk'] as int;
                  final topProduk = data['topProduk'] as List;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Kartu statistik 2x2 ─────────────────────
                      Row(
                        children: [
                          Expanded(child: _StatCard(
                            label: 'Total Revenue',
                            value: _formatRupiah(revenue),
                            sub: order.toString(),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            label: 'Average Order',
                            value: order > 0
                                ? _formatRupiah(revenue ~/ order)
                                : 'Rp. 0',
                            sub: order.toString(),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StatCard(
                            label: 'Total Customers',
                            value: customers.toString(),
                            sub: customers.toString(),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            label: 'Total Order',
                            value: order.toString(),
                            sub: produk.toString(),
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Produk Terlaris ──────────────────────────
                      const Text('Produk Terlaris',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...List.generate(topProduk.length, (i) {
                        final p = topProduk[i] as Map<String, dynamic>;
                        return _TopProdukTile(
                          rank     : p['rank'] as int,
                          nama     : p['nama'] as String,
                          imageUrl : p['imageUrl'] as String,
                          jumlahSewa: p['jumlahSewa'] as int,
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(fontSize: 11, color: Colors.black38)),
        ],
      ),
    );
  }
}

class _TopProdukTile extends StatelessWidget {
  final int rank;
  final String nama;
  final String imageUrl;
  final int jumlahSewa;

  const _TopProdukTile({
    required this.rank,
    required this.nama,
    required this.imageUrl,
    required this.jumlahSewa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Nomor urut
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF021427),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('$rank',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          // Gambar produk
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder())
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Nama
          Expanded(
            child: Text(nama,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          // Jumlah sewa
          Text('$jumlahSewa x',
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 48, height: 48,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 20),
      );
}