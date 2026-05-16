import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../user/presentation/user_page.dart';
//import '../../user/presentation/status_sewa_page.dart';

class StrukPage extends StatefulWidget {
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
  final String metodePembayaran;

  const StrukPage({
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
    required this.metodePembayaran,
  });

  @override
  State<StrukPage> createState() => _StrukPageState();
}

class _StrukPageState extends State<StrukPage> {
  List<String> _addonNames = [];

  @override
  void initState() {
    super.initState();
    _loadAddonNames();
  }

  Future<void> _loadAddonNames() async {
    if (widget.addonIds.isEmpty) return;
    final List<String> names = [];
    for (final id in widget.addonIds) {
      final doc = await FirebaseFirestore.instance
          .collection('produk')
          .doc(id)
          .get();
      if (doc.exists) {
        names.add(doc.data()?['nama_produk'] ?? '');
      }
    }
    if (mounted) setState(() => _addonNames = names);
  }

  String _formatTanggal(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _formatHarga(int h) => 'Rp. ${h.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';

  ImageProvider? _getImage(String g) {
    if (g.isEmpty) return null;
    if (g.startsWith('data:image')) {
      return MemoryImage(base64Decode(g.split(',').last));
    }
    return NetworkImage(g);
  }

  @override
  Widget build(BuildContext context) {
    final d         = widget.produkData;
    final nama      = widget.isPaket ? (d['nama_paket'] ?? '') : (d['nama_produk'] ?? '');
    final deskripsi = widget.isPaket ? (d['deskripsi_paket'] ?? '') : (d['deskripsi_produk'] ?? '');
    final gambar    = widget.isPaket ? (d['gambar_paket'] ?? '') : (d['gambar_produk'] ?? '');
    final hargaPokok= widget.isPaket
        ? (d['harga_paket'] ?? 0) as int
        : (d['harga_sewa'] ?? 0) as int;
    final imageProvider = _getImage(gambar);

    // Kode produk dari no resi
    final kodeProduk = '${nama.replaceAll(' ', '').toUpperCase().substring(0, nama.length > 6 ? 6 : nama.length)}-IV';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Struk Pembayaran Sewa Produk',
          style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Info produk ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageProvider != null
                        ? Image(
                            image: imageProvider,
                            width: 80, height: 80,
                            fit: BoxFit.cover)
                        : Container(
                            width: 80, height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nama,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(deskripsi,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _chip(Icons.star_rounded, Colors.amber,
                                widget.kondisi >= 90 ? '4.8' : '4.0'),
                            const SizedBox(width: 6),
                            _chip(Icons.shield_outlined, Colors.blue,
                                '${widget.kondisi}%'),
                            const SizedBox(width: 6),
                            _chip(Icons.favorite_border,
                                Colors.redAccent,
                                '${widget.jumlahDisukai}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Detail Penyewaan & Transaksi ──
            _section(
              title: 'Detail Penyewaan & Transaksi',
              children: [
                _row('Kode produk', kodeProduk),
                _row('Add-on',
                    _addonNames.isEmpty ? '-' : _addonNames.join(', ')),
                _row('Sewa perhari',
                    '${_formatHarga(hargaPokok)}/hari'),
                _row('Durasi sewa', '7 hari'),
                _row('Total biaya', _formatHarga(widget.total)),
                _row('Diskon', '-'),
                _row('Kembali', '-'),
              ],
            ),
            const SizedBox(height: 12),

            // ── Tanggal Penyewaan ──
            _section(
              title: 'Tanggal Penyewaan',
              children: [
                _row('Mulai',
                    _formatTanggal(widget.tanggalMulai)),
                _row('Selesai',
                    _formatTanggal(widget.tanggalSelesai)),
              ],
            ),
            const SizedBox(height: 12),

            // ── Metode Pembayaran ──
            _section(
              title: 'Metode Pembayaran',
              children: [
                _row('', '${widget.metodePembayaran} - LUNAS'),
              ],
            ),
            const SizedBox(height: 12),

            // ── No. Resi ──
            _section(
              title: 'No. Resi',
              children: [
                _row('', widget.noResi),
              ],
            ),
            const SizedBox(height: 16),

            // Footer note
            const Text(
              'Simpan struk ini untuk syarat pengambilan di toko.\nTerimakasih sudah menyewa di Ruang Lensa :)',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),

      // ── Tombol Selesai ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserPage()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF021427),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Selesai',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: label.isEmpty
          ? Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.black87))
          : Text('$label: $value',
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }

  Widget _chip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}