import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pemesanan_page.dart';

class DetailProdukPage extends StatefulWidget {
  final String produkId;
  final bool isPaket;

  const DetailProdukPage({
    super.key,
    required this.produkId,
    this.isPaket = false,
  });

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isDisukai = false;
  int  _jumlahDisukai = 0;
  String? _disukaiDocId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final col = widget.isPaket ? 'paket' : 'produk';

    print('Loading dari koleksi: $col');
    print('produkId: ${widget.produkId}');

    final doc = await FirebaseFirestore.instance
        .collection(col)
        .doc(widget.produkId)
        .get();

    print('doc.exists: ${doc.exists}');
    print('doc.data: ${doc.data()}');

    final uid = FirebaseAuth.instance.currentUser?.uid;
    bool isDisukai = false;
    String? disukaiDocId;

    if (uid != null) {
      final snap = await FirebaseFirestore.instance
          .collection('pesanan_disukai')
          .where('user_id', isEqualTo: uid)
          .where('produk_id', isEqualTo: widget.produkId)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        isDisukai    = true;
        disukaiDocId = snap.docs.first.id;
      }
    }

    final countSnap = await FirebaseFirestore.instance
        .collection('pesanan_disukai')
        .where('produk_id', isEqualTo: widget.produkId)
        .count()
        .get();

    if (mounted) {
      setState(() {
        _data          = doc.data();
        _isDisukai     = isDisukai;
        _disukaiDocId  = disukaiDocId;
        _jumlahDisukai = countSnap.count ?? 0;
        _isLoading     = false;
      });
    }
  }

  Future<void> _toggleDisukai() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_isDisukai && _disukaiDocId != null) {
      await FirebaseFirestore.instance
          .collection('pesanan_disukai')
          .doc(_disukaiDocId)
          .delete();
      setState(() {
        _isDisukai     = false;
        _disukaiDocId  = null;
        _jumlahDisukai = (_jumlahDisukai - 1).clamp(0, 999999);
      });
    } else {
      final ref = await FirebaseFirestore.instance
          .collection('pesanan_disukai')
          .add({
        'user_id'   : uid,
        'produk_id' : widget.produkId,
        'created_at': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isDisukai     = true;
        _disukaiDocId  = ref.id;
        _jumlahDisukai = _jumlahDisukai + 1;
      });
    }
  }

  Future<void> _tambahKeKeranjang() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final existing = await FirebaseFirestore.instance
        .collection('keranjang')
        .where('user_id', isEqualTo: uid)
        .where('produk_id', isEqualTo: widget.produkId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk sudah ada di keranjang')),
        );
      }
      return;
    }

    await FirebaseFirestore.instance.collection('keranjang').add({
      'user_id'   : uid,
      'produk_id' : widget.produkId,
      'created_at': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil ditambahkan ke keranjang!'),
          backgroundColor: Color(0xFF021427),
        ),
      );
    }
  }

  ImageProvider? _getImage(String g) {
    if (g.isEmpty) return null;
    if (g.startsWith('data:image')) {
      return MemoryImage(base64Decode(g.split(',').last));
    }
    return NetworkImage(g);
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return const Scaffold(
        body: Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final d             = _data!;
    final isPaket       = widget.isPaket;
    final nama          = isPaket ? (d['nama_paket'] ?? '') : (d['nama_produk'] ?? '');
    final harga         = isPaket ? (d['harga_paket'] ?? 0) as int : (d['harga_sewa'] ?? 0) as int;
    final durasi        = isPaket ? null : (d['durasi_sewa'] ?? 7) as int;
    final deskripsi     = isPaket ? (d['deskripsi_paket'] ?? '') : (d['deskripsi_produk'] ?? '');
    final kondisi       = isPaket ? null : (d['kondisi_produk'] ?? 0) as int;
    final status        = isPaket ? (d['status_paket'] ?? '') : (d['status_produk'] ?? '');
    final gambar        = isPaket ? (d['gambar_paket'] ?? '') : (d['gambar_produk'] ?? '');
    final imageProvider = _getImage(gambar);

    final hargaStr = isPaket
        ? 'Rp. ${_formatHarga(harga)}/paket'
        : 'Rp. ${_formatHarga(harga)}/hari';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          isPaket ? 'Paket' : 'Produk',
          style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar produk ──
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageProvider != null
                    ? Image(
                        image: imageProvider,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // ── Info utama ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(hargaStr,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Tersedia'
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: status == 'Tersedia'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 12,
                              color: status == 'Tersedia'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                color: status == 'Tersedia'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Rating chips
                  Row(
                    children: [
                      // Kondisi (hanya produk, bukan paket)
                      if (kondisi != null) ...[
                        _chip(
                          icon: Icons.star_rounded,
                          color: Colors.amber,
                          label: kondisi >= 90
                              ? '4.8'
                              : kondisi >= 70
                                  ? '4.0'
                                  : '3.5',
                        ),
                        const SizedBox(width: 8),
                        _chip(
                          icon: Icons.shield_outlined,
                          color: Colors.blue,
                          label: '$kondisi%',
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Disukai
                      GestureDetector(
                        onTap: _toggleDisukai,
                        child: _chip(
                          icon: _isDisukai
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.redAccent,
                          label: '$_jumlahDisukai',
                          filled: _isDisukai,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Deskripsi ──
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deskripsi,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // ── Bottom bar ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tombol keranjang
            GestureDetector(
              onTap: _tambahKeKeranjang,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF021427)),
              ),
            ),
            const SizedBox(width: 12),
            // Tombol sewa sekarang
            Expanded(
              child: ElevatedButton(
                onPressed: status == 'Tersedia'
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PemesananPage(
                              produkId : widget.produkId,
                              isPaket  : widget.isPaket,
                              produkData: _data!,
                              jumlahDisukai: _jumlahDisukai,
                              kondisi  : kondisi ?? 0,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF021427),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sewa sekarang',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required Color color,
    required String label,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}