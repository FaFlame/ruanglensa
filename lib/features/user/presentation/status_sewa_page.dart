// lib/pages/status_sewa_page.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruanglensa/features/admin/presentation/sewa_model.dart';
import 'package:ruanglensa/features/user/presentation/produk_model.dart';
import 'detail_sewa_page.dart';

class StatusSewaPage extends StatefulWidget {
  const StatusSewaPage({super.key});

  @override
  State<StatusSewaPage> createState() => _StatusSewaPageState();
}

class _StatusSewaPageState extends State<StatusSewaPage> {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late Future<List<SewaWithProduk>> _sewaFuture;

  @override
  void initState() {
    super.initState();
    _sewaFuture = _fetchSewa();
  }

  Future<List<SewaWithProduk>> _fetchSewa() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snap = await _db
        .collection('sewa')
        .where('user_id', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .get();

    final sewaList = snap.docs
        .map((doc) => Sewa.fromFirestore(doc.data(), doc.id))
        .toList();

    final List<SewaWithProduk> result = [];
    for (final sewa in sewaList) {
      Produk? produk;
      if (sewa.produkId.isNotEmpty) {
        final produkDoc =
            await _db.collection('produk').doc(sewa.produkId).get();
        if (produkDoc.exists) {
          produk = Produk.fromFirestore(produkDoc.data()!, produkDoc.id);
        }
      }
      result.add(SewaWithProduk(sewa: sewa, produk: produk));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Center(
              child: Text('Status Sewa',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // ── Daftar sewa ────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<SewaWithProduk>>(
              future: _sewaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Belum ada sewa.',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _sewaFuture = _fetchSewa());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 14),
                    itemBuilder: (_, i) => _SewaCard(data: list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kartu sewa
// ─────────────────────────────────────────────────────────────────────────────
class _SewaCard extends StatelessWidget {
  final SewaWithProduk data;
  const _SewaCard({required this.data});

  _StatusStyle get _statusStyle {
    switch (data.sewa.statusPesanan) {
      case 'Berlangsung':
        return _StatusStyle(
            color: const Color(0xFF4CAF50),
            label: 'Masa sewa berlangsung');
      case 'Akan Berakhir':
        return _StatusStyle(
            color: const Color(0xFFFFC107),
            label: 'Masa sewa akan berakhir');
      default:
        return _StatusStyle(
            color: const Color(0xFFEF5350),
            label: 'Masa sewa telah berakhir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sewa   = data.sewa;
    final produk = data.produk;
    final style  = _statusStyle;

    Uint8List? imageBytes;
    if (produk != null && produk.gambarProduk.isNotEmpty) {
      imageBytes = base64Decode(produk.gambarProduk);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailSewaPage(data: data)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nama + gambar ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk?.namaProduk ?? 'Produk tidak ditemukan',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mulai : ${Sewa.formatTanggal(sewa.tanggalMulai)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        'Selesai : ${Sewa.formatTanggal(sewa.tanggalSelesai)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageBytes != null
                      ? Image.memory(imageBytes,
                          width: 90, height: 70, fit: BoxFit.cover)
                      : Container(
                          width: 90,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Sisa hari ───────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text('${sewa.sisaHari} hari lagi',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 8),

            // ── Progress bar ────────────────────────────────────────
            _SegmentProgressBar(
              progress: sewa.progressNilai,
              color: style.color,
              segments: sewa.durasiHari > 0 ? sewa.durasiHari : 7,
            ),
            const SizedBox(height: 12),

            // ── Tombol status ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(style.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress bar segmen ────────────────────────────────────────────────────
class _SegmentProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final int segments;

  const _SegmentProgressBar({
    required this.progress,
    required this.color,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final filled = (progress * segments).round().clamp(0, segments);

    return Row(
      children: List.generate(segments, (i) {
        final isFilled = i < filled;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i < segments - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isFilled ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _StatusStyle {
  final Color color;
  final String label;
  const _StatusStyle({required this.color, required this.label});
}