// lib/models/sewa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruanglensa/features/user/presentation/produk_model.dart';

class Sewa {
  final String id;
  final String userId;
  final String produkId;
  final String? paketId;
  final List<String> addonIds;       // field baru: addon_ids di Firestore
  final int durasiHari;
  final String metodePembayaran;
  final String noResi;               // field baru: no_resi di Firestore
  final String statusPesanan;        // "Berlangsung" | "Akan Berakhir" | "Berakhir"
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int total;
  final DateTime createdAt;

  const Sewa({
    required this.id,
    required this.userId,
    required this.produkId,
    this.paketId,
    required this.addonIds,
    required this.durasiHari,
    required this.metodePembayaran,
    required this.noResi,
    required this.statusPesanan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.total,
    required this.createdAt,
  });

  factory Sewa.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      return DateTime.now();
    }

    final addonRaw = data['addon_ids'];
    final addonIds = addonRaw is List
        ? addonRaw.map((e) => e.toString()).toList()
        : <String>[];

    return Sewa(
      id: docId,
      userId: data['user_id'] ?? '',
      produkId: data['produk_id'] ?? '',
      paketId: data['paket_id'],
      addonIds: addonIds,
      durasiHari: (data['durasi_hari'] ?? 0).toInt(),
      metodePembayaran: data['metode_pembayaran'] ?? '',
      noResi: data['no_resi'] ?? '',
      statusPesanan: data['status_pesanan'] ?? '',
      tanggalMulai: parseDate(data['tanggal_mulai']),
      tanggalSelesai: parseDate(data['tanggal_selesai']),
      total: (data['total'] ?? 0).toInt(),
      createdAt: parseDate(data['created_at']),
    );
  }

  // Format total → "Rp. 3.500.000"
  String get totalFormatted {
    final str = total.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $str';
  }

  // Sisa hari sebelum tanggal selesai
  int get sisaHari {
    final now = DateTime.now();
    final sisa = tanggalSelesai.difference(now).inDays;
    return sisa < 0 ? 0 : sisa;
  }

  // Progress 0.0 - 1.0 (untuk progress bar)
  double get progressNilai {
    final totalDurasi = tanggalSelesai.difference(tanggalMulai).inDays;
    final terpakai = DateTime.now().difference(tanggalMulai).inDays;
    if (totalDurasi <= 0) return 1.0;
    return (terpakai / totalDurasi).clamp(0.0, 1.0);
  }

  // Format tanggal → "05/05/2026"
  static String formatTanggal(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class — pasangan Sewa + Produk (dipakai di status & detail sewa page)
// ─────────────────────────────────────────────────────────────────────────────
class SewaWithProduk {
  final Sewa sewa;
  final Produk? produk;
  const SewaWithProduk({required this.sewa, this.produk});
}
