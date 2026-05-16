import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisukaiPage extends StatefulWidget {
  const DisukaiPage({super.key});

  @override
  State<DisukaiPage> createState() => _DisukaiPageState();
}

class _DisukaiPageState extends State<DisukaiPage> {
  List<Map<String, dynamic>> _disukaiList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDisukai();
  }

  Future<void> _loadDisukai() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() {
          _error = 'User tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      // Ambil semua pesanan_disukai milik user ini
      final disukaiSnapshot = await FirebaseFirestore.instance
          .collection('pesanan_disukai')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      if (disukaiSnapshot.docs.isEmpty) {
        setState(() {
          _disukaiList = [];
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> result = [];

      for (final doc in disukaiSnapshot.docs) {
        final data     = doc.data();
        final produkId = data['produk_id'] as String? ?? '';

        String namaProduk    = '';
        String gambarProduk  = '';
        String hargaProduk   = '';
        String deskripsi     = '';
        int    jumlahDisukai = 0;

        if (produkId.isNotEmpty) {
          // Coba cari di collection produk dulu
          final produkDoc = await FirebaseFirestore.instance
              .collection('produk')
              .doc(produkId)
              .get();

          if (produkDoc.exists) {
            final d        = produkDoc.data()!;
            namaProduk     = d['nama_produk']    ?? '';
            gambarProduk   = d['gambar_produk']  ?? '';
            deskripsi      = d['deskripsi_produk'] ?? '';
            final harga    = (d['harga_sewa'] ?? 0).toInt();
            final durasi   = (d['durasi_sewa'] ?? 7).toInt();
            final hargaStr = harga.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.',
            );
            hargaProduk = 'Rp. $hargaStr/$durasi hari';
          } else {
            // Kalau tidak ada di produk, coba di paket
            final paketDoc = await FirebaseFirestore.instance
                .collection('paket')
                .doc(produkId)
                .get();

            if (paketDoc.exists) {
              final d      = paketDoc.data()!;
              namaProduk   = d['nama_paket']    ?? '';
              gambarProduk = d['gambar_paket']  ?? '';
              deskripsi    = d['deskripsi_paket'] ?? '';
              final harga  = (d['harga_paket'] ?? 0).toInt();
              final hargaStr = harga.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]}.',
              );
              hargaProduk = 'Rp. $hargaStr/paket';
            }
          }

          // Hitung total yang menyukai produk ini
          final countSnapshot = await FirebaseFirestore.instance
              .collection('pesanan_disukai')
              .where('produk_id', isEqualTo: produkId)
              .count()
              .get();
          jumlahDisukai = countSnapshot.count ?? 0;
        }

        result.add({
          'doc_id'        : doc.id,
          'produk_id'     : produkId,
          'nama_produk'   : namaProduk,
          'gambar_produk' : gambarProduk,
          'harga_produk'  : hargaProduk,
          'deskripsi'     : deskripsi,
          'jumlah_disukai': jumlahDisukai,
        });
      }

      setState(() {
        _disukaiList = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _hapusDisukai(String docId) async {
    await FirebaseFirestore.instance
        .collection('pesanan_disukai')
        .doc(docId)
        .delete();
    setState(() {
      _disukaiList.removeWhere((item) => item['doc_id'] == docId);
    });
  }

  ImageProvider? _getImageProvider(String gambar) {
    if (gambar.isEmpty) return null;
    if (gambar.startsWith('data:image')) {
      return MemoryImage(base64Decode(gambar.split(',').last));
    }
    return NetworkImage(gambar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Disukai',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadDisukai,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _disukaiList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada produk yang disukai',
                            style: TextStyle(
                                fontSize: 15, color: Colors.black45),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDisukai,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _disukaiList.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _disukaiList[index];
                          final gambar =
                              item['gambar_produk'] as String? ?? '';
                          final imageProvider =
                              _getImageProvider(gambar);
                          final jumlah =
                              item['jumlah_disukai'] as int? ?? 0;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Gambar produk ──
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageProvider != null
                                      ? Image(
                                          image: imageProvider,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 72,
                                          height: 72,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),

                                // ── Info produk ──
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama_produk'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['harga_produk'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['deskripsi'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      // Jumlah yang menyukai
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            size: 14,
                                            color: Colors.redAccent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$jumlah',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Tombol hapus dari disukai ──
                                IconButton(
                                  onPressed: () => _hapusDisukai(
                                      item['doc_id'] as String),
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  tooltip: 'Hapus dari disukai',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}