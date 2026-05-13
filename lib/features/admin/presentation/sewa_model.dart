// lib/models/sewa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Sewa {
  final String id;
  final String userId;
  final String produkId;
  final String? paketId;
  final int durasiHari;
  final String metodePembayaran;
  final String statusPesanan; // "Diproses" | "Selesai" | "Dibatalkan"
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int total;
  final DateTime createdAt;

  const Sewa({
    required this.id,
    required this.userId,
    required this.produkId,
    this.paketId,
    required this.durasiHari,
    required this.metodePembayaran,
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

    return Sewa(
      id: docId,
      userId: data['user_id'] ?? '',
      produkId: data['produk_id'] ?? '',
      paketId: data['paket_id'],
      durasiHari: (data['durasi_hari'] ?? 0).toInt(),
      metodePembayaran: data['metode_pembayaran'] ?? '',
      statusPesanan: data['status_pesanan'] ?? '',
      tanggalMulai: parseDate(data['tanggal_mulai']),
      tanggalSelesai: parseDate(data['tanggal_selesai']),
      total: (data['total'] ?? 0).toInt(),
      createdAt: parseDate(data['created_at']),
    );
  }

  // Format total untuk ditampilkan, contoh: "Rp. 429.000"
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
    return tanggalSelesai.difference(now).inDays;
  }

  // Format tanggal, contoh: "05-05-2026"
  static String formatTanggal(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year}';
  }
}