// lib/pages/search_page.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'produk_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();
  final _db = FirebaseFirestore.instance;

  List<String> _riwayat = [];
  List<Produk> _hasilProduk = [];
  List<Paket> _hasilPaket = [];
  bool _isLoading = false;
  bool _sudahCari = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Cari produk & paket dari Firestore ───────────────────────────────────
  Future<void> _cari() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    // Simpan ke riwayat
    setState(() {
      _riwayat.remove(query);
      _riwayat.insert(0, query);
      if (_riwayat.length > 5) _riwayat = _riwayat.take(5).toList();
      _isLoading = true;
      _sudahCari = false;
    });

    FocusScope.of(context).unfocus();

    try {
      // Cari di koleksi produk
      final produkSnap = await _db
          .collection('produk')
          .where('status_produk', isEqualTo: 'Tersedia')
          .get();

      // Cari di koleksi paket
      final paketSnap = await _db
          .collection('paket')
          .where('status_paket', isEqualTo: 'Tersedia')
          .get();

      // Filter hasil yang mengandung kata pencarian (case insensitive)
      final queryLower = query.toLowerCase();

      final produkHasil = produkSnap.docs
          .where((doc) {
            final nama = (doc.data()['nama_produk'] ?? '').toLowerCase();
            final kategori =
                (doc.data()['kategori_produk'] ?? '').toLowerCase();
            return nama.contains(queryLower) ||
                kategori.contains(queryLower);
          })
          .map((doc) => Produk.fromFirestore(doc.data(), doc.id))
          .toList();

      final paketHasil = paketSnap.docs
          .where((doc) {
            final nama = (doc.data()['nama_paket'] ?? '').toLowerCase();
            return nama.contains(queryLower);
          })
          .map((doc) => Paket.fromFirestore(doc.data(), doc.id))
          .toList();

      if (mounted) {
        setState(() {
          _hasilProduk = produkHasil;
          _hasilPaket  = paketHasil;
          _isLoading   = false;
          _sudahCari   = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari: $e')),
        );
      }
    }
  }

  // ── Hapus satu riwayat ───────────────────────────────────────────────────
  void _hapusRiwayat(String item) {
    setState(() => _riwayat.remove(item));
  }

  // ── Tap riwayat → isi search bar langsung cari ───────────────────────────
  void _tapRiwayat(String item) {
    _searchCtrl.text = item;
    _cari();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        size: 22, color: Color(0xFF021427)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Pencarian',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 22), // penyeimbang ikon back
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────
       Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        // Search bar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _cari(),
                    decoration: const InputDecoration(
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

        // Tombol Cari
        GestureDetector(
          onTap: _cari,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: const Color(0xFF021427),
              borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),

            // ── Konten ─────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_sudahCari
                      ? _buildRiwayat()
                      : _buildHasil(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tampilan riwayat pencarian ─────────────────────────────────────────
  Widget _buildRiwayat() {
    if (_riwayat.isEmpty) return const SizedBox();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _riwayat.length,
      itemBuilder: (_, i) {
        final item = _riwayat[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _tapRiwayat(item),
                child: Text(item,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87)),
              ),
              GestureDetector(
                onTap: () => _hapusRiwayat(item),
                child: const Icon(Icons.close,
                    size: 18, color: Colors.black45),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tampilan hasil pencarian ──────────────────────────────────────────
  Widget _buildHasil() {
    final totalHasil = _hasilProduk.length + _hasilPaket.length;

    if (totalHasil == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil untuk "${_searchCtrl.text}"',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$totalHasil hasil ditemukan',
              style: const TextStyle(
                  fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),

          // Grid hasil
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
            children: [
              ..._hasilProduk.map((p) => _HasilProdukCard(produk: p)),
              ..._hasilPaket.map((p) => _HasilPaketCard(paket: p)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card hasil produk ──────────────────────────────────────────────────────
class _HasilProdukCard extends StatelessWidget {
  final Produk produk;
  const _HasilProdukCard({required this.produk});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (produk.gambarProduk.isNotEmpty) {
      imageBytes = base64Decode(produk.gambarProduk);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageBytes != null
              ? Image.memory(imageBytes,
                  width: double.infinity, height: 88, fit: BoxFit.cover)
              : _placeholder(),
        ),
        const SizedBox(height: 6),
        Text(produk.namaProduk,
            style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(produk.hargaFormatted,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
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

// ── Card hasil paket ───────────────────────────────────────────────────────
class _HasilPaketCard extends StatelessWidget {
  final Paket paket;
  const _HasilPaketCard({required this.paket});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (paket.gambarPaket.isNotEmpty) {
      imageBytes = base64Decode(paket.gambarPaket);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageBytes != null
              ? Image.memory(imageBytes,
                  width: double.infinity, height: 88, fit: BoxFit.cover)
              : _placeholder(),
        ),
        const SizedBox(height: 6),
        Text(paket.namaPaket,
            style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(paket.hargaFormatted,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
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