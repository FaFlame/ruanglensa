import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'struk_page.dart';

class QrisBottomSheet extends StatefulWidget {
  final String sewaId;
  final String noResi;
  final int total;
  final Map<String, dynamic> produkData;
  final bool isPaket;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final List<String> addonIds;
  final int kondisi;
  final int jumlahDisukai;

  const QrisBottomSheet({
    super.key,
    required this.sewaId,
    required this.noResi,
    required this.total,
    required this.produkData,
    required this.isPaket,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.addonIds,
    required this.kondisi,
    required this.jumlahDisukai,
  });

  @override
  State<QrisBottomSheet> createState() => _QrisBottomSheetState();
}

class _QrisBottomSheetState extends State<QrisBottomSheet> {
  // Countdown 3 jam = 10800 detik
  int _secondsLeft = 10800;
  Timer? _timer;
  bool _isMeninjau = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerText {
    final h = _secondsLeft ~/ 3600;
    final m = (_secondsLeft % 3600) ~/ 60;
    final s = _secondsLeft % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  Future<void> _cekPembayaran() async {
    setState(() => _isMeninjau = true);
    _timer?.cancel();

    // Simulasi pengecekan 2 detik lalu konfirmasi lunas
    await Future.delayed(const Duration(seconds: 2));

    // Update status sewa jadi Berlangsung
    await FirebaseFirestore.instance
        .collection('sewa')
        .doc(widget.sewaId)
        .update({
      'status_pesanan': 'Berlangsung',
      'updated_at'    : FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    // Tutup bottom sheet
    Navigator.pop(context);

    // Navigasi ke struk
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StrukPage(
          sewaId        : widget.sewaId,
          noResi        : widget.noResi,
          total         : widget.total,
          produkData    : widget.produkData,
          isPaket       : widget.isPaket,
          tanggalMulai  : widget.tanggalMulai,
          tanggalSelesai: widget.tanggalSelesai,
          addonIds      : widget.addonIds,
          kondisi       : widget.kondisi,
          jumlahDisukai : widget.jumlahDisukai,
          metodePembayaran: 'QRIS',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── QR Code area ──
          Container(
            width: 220,
            height: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gambar QR
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/qris.png',
                    fit: BoxFit.contain,
                  ),
                ),
                // Overlay "meninjau"
                if (_isMeninjau)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Kami sedang meninjau\npembayaran anda',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Selesaikan Pembayaran',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Scan atau simpan QRIS untuk melanjutkan\npembayaran Anda dalam waktu',
            style: TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Countdown timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined,
                  size: 16, color: Color(0xFF021427)),
              const SizedBox(width: 6),
              Text(
                _timerText,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF021427)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Unduh QRIS
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fitur unduh QRIS segera hadir')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF021427),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Unduh QRIS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Cek status pembayaran
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isMeninjau ? null : _cekPembayaran,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isMeninjau
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF021427)))
                  : const Text('Cek status pembayaran',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}