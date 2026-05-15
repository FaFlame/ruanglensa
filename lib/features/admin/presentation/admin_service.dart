// lib/services/admin_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../user/presentation/produk_model.dart';
import 'sewa_model.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — Konversi gambar ke Base64
  // ─────────────────────────────────────────────────────────────────────────

  // Terima Uint8List (bytes) dari image_picker, kembalikan Base64 string
  String toBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUK — CRUD
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Produk>> fetchSemuaProduk() async {
    final snapshot = await _db
        .collection('produk')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Produk.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> tambahProduk({
    required String namaProduk,
    required int hargaSewa,
    required int durasiSewa,
    required String kategoriProduk,
    required String deskripsiProduk,
    required int kondisiProduk,
    required String statusProduk,
    Uint8List? imageBytes, // bytes dari image_picker
  }) async {
    final String gambarProduk =
        imageBytes != null ? toBase64(imageBytes) : '';

    await _db.collection('produk').add({
      'nama_produk'     : namaProduk,
      'harga_sewa'      : hargaSewa,
      'durasi_sewa'     : durasiSewa,
      'kategori_produk' : kategoriProduk,
      'deskripsi_produk': deskripsiProduk,
      'kondisi_produk'  : kondisiProduk,
      'status_produk'   : statusProduk,
      'gambar_produk'   : gambarProduk,
      'created_at'      : FieldValue.serverTimestamp(),
      'updated_at'      : FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduk({
    required String docId,
    String? namaProduk,
    int? hargaSewa,
    int? durasiSewa,
    String? kategoriProduk,
    String? deskripsiProduk,
    int? kondisiProduk,
    String? statusProduk,
    Uint8List? imageBytes,
  }) async {
    final Map<String, dynamic> data = {};

    if (namaProduk != null)      data['nama_produk']      = namaProduk;
    if (hargaSewa != null)       data['harga_sewa']       = hargaSewa;
    if (durasiSewa != null)      data['durasi_sewa']      = durasiSewa;
    if (kategoriProduk != null)  data['kategori_produk']  = kategoriProduk;
    if (deskripsiProduk != null) data['deskripsi_produk'] = deskripsiProduk;
    if (kondisiProduk != null)   data['kondisi_produk']   = kondisiProduk;
    if (statusProduk != null)    data['status_produk']    = statusProduk;
    if (imageBytes != null)      data['gambar_produk']    = toBase64(imageBytes);

    data['updated_at'] = FieldValue.serverTimestamp();
    await _db.collection('produk').doc(docId).update(data);
  }

  Future<void> hapusProduk(String docId) async {
    await _db.collection('produk').doc(docId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAKET — CRUD
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Paket>> fetchSemuaPaket() async {
    final snapshot = await _db
        .collection('paket')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Paket.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> tambahPaket({
    required String namaPaket,
    required int hargaPaket,
    required String kategoriPaket,
    required String deskripsiPaket,
    required String statusPaket,
    Uint8List? imageBytes,
  }) async {
    final String gambarPaket =
        imageBytes != null ? toBase64(imageBytes) : '';

    await _db.collection('paket').add({
      'nama_paket'     : namaPaket,
      'harga_paket'    : hargaPaket,
      'kategori_paket' : kategoriPaket,
      'deskripsi_paket': deskripsiPaket,
      'status_paket'   : statusPaket,
      'gambar_paket'   : gambarPaket,
      'created_at'     : FieldValue.serverTimestamp(),
      'updated_at'     : FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePaket({
    required String docId,
    String? namaPaket,
    int? hargaPaket,
    String? kategoriPaket,
    String? deskripsiPaket,
    String? statusPaket,
    Uint8List? imageBytes,
  }) async {
    final Map<String, dynamic> data = {};

    if (namaPaket != null)      data['nama_paket']      = namaPaket;
    if (hargaPaket != null)     data['harga_paket']     = hargaPaket;
    if (kategoriPaket != null)  data['kategori_paket']  = kategoriPaket;
    if (deskripsiPaket != null) data['deskripsi_paket'] = deskripsiPaket;
    if (statusPaket != null)    data['status_paket']    = statusPaket;
    if (imageBytes != null)     data['gambar_paket']    = toBase64(imageBytes);

    data['updated_at'] = FieldValue.serverTimestamp();
    await _db.collection('paket').doc(docId).update(data);
  }

  Future<void> hapusPaket(String docId) async {
    await _db.collection('paket').doc(docId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEWA (PESANAN) — Read & Update Status
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Sewa>> fetchSemuaPesanan() async {
    final snapshot = await _db
        .collection('sewa')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Sewa.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<Sewa>> fetchPesananByStatus(String status) async {
    final snapshot = await _db
        .collection('sewa')
        .where('status_pesanan', isEqualTo: status)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Sewa.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateStatusPesanan(String docId, String status) async {
    await _db.collection('sewa').doc(docId).update({
      'status_pesanan': status,
      'updated_at'    : FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STATISTIK — untuk halaman Beranda admin
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchStatistik() async {
    final sewaSnap   = await _db.collection('sewa').get();
    final usersSnap  = await _db.collection('users').get();
    final produkSnap = await _db.collection('produk').get();

    int totalRevenue = 0;
    final Map<String, int> produkCount = {};

    for (final doc in sewaSnap.docs) {
      final data = doc.data();
      totalRevenue += (data['total'] ?? 0) as int;

      final produkId = data['produk_id']?.toString() ?? '';
      if (produkId.isNotEmpty) {
        produkCount[produkId] = (produkCount[produkId] ?? 0) + 1;
      }
    }

    final sorted = produkCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProdukIds = sorted.take(3).map((e) => e.key).toList();

    final List<Map<String, dynamic>> topProduk = [];
    for (int i = 0; i < topProdukIds.length; i++) {
      final doc = await _db.collection('produk').doc(topProdukIds[i]).get();
      if (doc.exists) {
        topProduk.add({
          'rank'        : i + 1,
          'nama'        : doc.data()?['nama_produk'] ?? '',
          'gambarProduk': doc.data()?['gambar_produk'] ?? '',
          'jumlahSewa'  : sorted[i].value,
        });
      }
    }

    return {
      'totalRevenue'  : totalRevenue,
      'totalOrder'    : sewaSnap.docs.length,
      'totalCustomers': usersSnap.docs.length,
      'totalProduk'   : produkSnap.docs.length,
      'topProduk'     : topProduk,
    };
  }
}