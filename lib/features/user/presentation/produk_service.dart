// lib/services/produk_service.dart
//
// Dependency di pubspec.yaml:
//   firebase_core: ^3.x.x
//   cloud_firestore: ^5.x.x

import 'package:cloud_firestore/cloud_firestore.dart';
import 'produk_model.dart';

class ProdukService {
  ProdukService._();
  static final ProdukService instance = ProdukService._();

  final _db = FirebaseFirestore.instance;

  // ── Koleksi "produk" (Kamera & Lensa) ────────────────────────────────────

  Future<List<Produk>> _fetchProdukByKategori(String kategori) async {
    final snapshot = await _db
        .collection('produk')
        .where('kategori_produk', isEqualTo: kategori)
        .where('status_produk', isEqualTo: 'Tersedia')
        .get();

    return snapshot.docs
        .map((doc) => Produk.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<Produk>> fetchKamera() => _fetchProdukByKategori('Kamera');
  Future<List<Produk>> fetchLensa()  => _fetchProdukByKategori('Lensa');

  // Penawaran Terbaik — ambil semua produk (kamera + lensa) yang tersedia,
  // tampilkan 9 teratas diurutkan dari yang terbaru ditambahkan admin
  Future<List<Produk>> fetchPenawaranTerbaik() async {
    final snapshot = await _db
        .collection('produk')
        .where('status_produk', isEqualTo: 'Tersedia')
        .where('kategori_produk', whereNotIn: ['Aksesori'])
        .orderBy('kategori_produk')
        .orderBy('created_at', descending: true)
        .limit(9)
        .get();

    return snapshot.docs
        .map((doc) => Produk.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // ── Koleksi "paket" (Paket Jasa) ─────────────────────────────────────────

  Future<List<Paket>> fetchPaketJasa() async {
    final snapshot = await _db
        .collection('paket')
        .where('status_paket', isEqualTo: 'Tersedia')
        .get();

    return snapshot.docs
        .map((doc) => Paket.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}