import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoriPesananPage extends StatefulWidget {
  const HistoriPesananPage({super.key});

  @override
  State<HistoriPesananPage> createState() => _HistoriPesananPageState();
}

class _HistoriPesananPageState extends State<HistoriPesananPage> {
  List<Map<String, dynamic>> _pesananList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistori();
  }

  Future<void> _loadHistori() async {
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

      // Ambil semua sewa milik user ini
      final sewaSnapshot = await FirebaseFirestore.instance
          .collection('sewa')
          .where('user_id', isEqualTo: uid)
          .orderBy('tanggal_mulai', descending: true)
          .get();

      if (sewaSnapshot.docs.isEmpty) {
        setState(() {
          _pesananList = [];
          _isLoading = false;
        });
        return;
      }

      // Untuk setiap sewa, ambil detail produk/paket
      final List<Map<String, dynamic>> result = [];

      for (final sewaDoc in sewaSnapshot.docs) {
        final sewaData = sewaDoc.data();
        final produkId = sewaData['produk_id'] as String?;
        final paketId  = sewaData['paket_id']  as String?;

        String namaProduk   = '';
        String gambarProduk = '';

        if (produkId != null && produkId.isNotEmpty) {
          // Ambil dari collection produk
          final produkDoc = await FirebaseFirestore.instance
              .collection('produk')
              .doc(produkId)
              .get();
          if (produkDoc.exists) {
            final d = produkDoc.data()!;
            namaProduk   = d['nama_produk']   ?? '';
            gambarProduk = d['gambar_produk'] ?? '';
          }
        } else if (paketId != null && paketId.isNotEmpty) {
          // Ambil dari collection paket
          final paketDoc = await FirebaseFirestore.instance
              .collection('paket')
              .doc(paketId)
              .get();
          if (paketDoc.exists) {
            final d = paketDoc.data()!;
            namaProduk   = d['nama_paket']   ?? '';
            gambarProduk = d['gambar_paket'] ?? '';
          }
        }

        result.add({
          'id'             : sewaDoc.id,
          'nama_produk'    : namaProduk,
          'gambar_produk'  : gambarProduk,
          'tanggal_mulai'  : sewaData['tanggal_mulai'],
          'tanggal_selesai': sewaData['tanggal_selesai'],
          'durasi_hari'    : sewaData['durasi_hari'] ?? 0,
          'status_pesanan' : sewaData['status_pesanan'] ?? '',
        });
      }

      setState(() {
        _pesananList = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat histori: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTanggal(dynamic timestamp) {
    if (timestamp == null) return '-';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else {
      return '-';
    }
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return const Color(0xFF4CAF50); // hijau
      case 'menunggu':
        return const Color(0xFFFF9800); // kuning/orange
      case 'selesai':
      case 'masa sewa telah berakhir':
        return const Color(0xFF9E9E9E); // abu-abu
      case 'dibatalkan':
        return const Color(0xFFF44336); // merah
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return 'Masa Sewa Berlangsung';
      case 'menunggu':
        return 'Menunggu Konfirmasi';
      case 'selesai':
        return 'Masa sewa telah berakhir';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
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
          'Histori Pesanan',
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
                        onPressed: _loadHistori,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _pesananList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada histori pesanan',
                            style: TextStyle(
                                fontSize: 15, color: Colors.black45),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistori,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pesananList.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _pesananList[index];
                          final gambar =
                              item['gambar_produk'] as String? ?? '';
                          final imageProvider =
                              _getImageProvider(gambar);
                          final status =
                              item['status_pesanan'] as String? ?? '';
                          final durasi = item['durasi_hari'] ?? 0;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Baris atas: nama + gambar ──
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nama_produk'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mulai : ${_formatTanggal(item['tanggal_mulai'])}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                          Text(
                                            'Selesai : ${_formatTanggal(item['tanggal_selesai'])}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: imageProvider != null
                                          ? Image(
                                              image: imageProvider,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 64,
                                              height: 64,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported_outlined,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // ── Durasi ──
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 14,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$durasi Hari Peminjaman',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // ── Status + Sewa Kembali ──
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _statusLabel(status),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Sewa kembali',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
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