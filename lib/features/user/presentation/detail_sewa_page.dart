// lib/pages/detail_sewa_page.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ruanglensa/features/admin/presentation/sewa_model.dart';
import 'package:ruanglensa/features/user/presentation/produk_model.dart';

class DetailSewaPage extends StatelessWidget {
  final SewaWithProduk data;
  const DetailSewaPage({super.key, required this.data});

  _StatusStyle get _statusStyle {
    switch (data.sewa.statusPesanan) {
      case 'Berlangsung':
        return _StatusStyle(
            color: const Color(0xFF4CAF50),
            label: 'Masa Sewa Berlangsung');
      case 'Akan Berakhir':
        return _StatusStyle(
            color: const Color(0xFFFFC107),
            label: 'Masa Sewa Akan Berakhir');
      default:
        return _StatusStyle(
            color: const Color(0xFFEF5350),
            label: 'Masa Sewa Telah Berakhir');
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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back,
                                size: 22, color: Color(0xFF021427)),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text('Detail Produk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 22),
                        ],
                      ),
                    ),

                    // ── Gambar produk besar ──────────────────────────
                    Container(
                      width: double.infinity,
                      height: 260,
                      color: Colors.white,
                      child: imageBytes != null
                          ? Image.memory(imageBytes, fit: BoxFit.contain)
                          : const Icon(
                              Icons.image_not_supported_outlined,
                              size: 60,
                              color: Colors.grey),
                    ),

                    // ── Info produk ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama produk
                          Text(
                            produk?.namaProduk ?? 'Produk tidak ditemukan',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),

                          // Harga
                          Text(
                            produk?.hargaFormatted ?? '-',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),

                          // Progress bar
                          _SegmentProgressBar(
                            progress: sewa.progressNilai,
                            color: style.color,
                            segments:
                                sewa.durasiHari > 0 ? sewa.durasiHari : 7,
                          ),
                          const SizedBox(height: 10),

                          // Sisa hari
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text('${sewa.sisaHari} hari lagi',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Deskripsi produk
                          if (produk?.deskripsiProduk.isNotEmpty == true) ...[
                            Text(
                              produk!.deskripsiProduk,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.5),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Detail sewa
                          _DetailRow(
                              label: 'No. Resi', value: sewa.noResi),
                          _DetailRow(
                              label: 'Tanggal Mulai',
                              value: Sewa.formatTanggal(sewa.tanggalMulai)),
                          _DetailRow(
                              label: 'Tanggal Selesai',
                              value: Sewa.formatTanggal(sewa.tanggalSelesai)),
                          _DetailRow(
                              label: 'Durasi',
                              value: '${sewa.durasiHari} hari'),
                          _DetailRow(
                              label: 'Metode Pembayaran',
                              value: sewa.metodePembayaran),
                          _DetailRow(
                              label: 'Total', value: sewa.totalFormatted),
                          _DetailRow(
                              label: 'Status', value: sewa.statusPesanan),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol status di bawah ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: style.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(style.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail row ─────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
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