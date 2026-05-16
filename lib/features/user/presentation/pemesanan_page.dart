import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qris_bottom_sheet.dart';

class PemesananPage extends StatefulWidget {
  final String produkId;
  final bool isPaket;
  final Map<String, dynamic> produkData;
  final int jumlahDisukai;
  final int kondisi;

  const PemesananPage({
    super.key,
    required this.produkId,
    required this.isPaket,
    required this.produkData,
    required this.jumlahDisukai,
    required this.kondisi,
  });

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  List<Map<String, dynamic>> _addonList = [];
  final Set<String> _selectedAddonIds = {};
  DateTime? _tanggalMulai;
  String _metodePembayaran = 'QRIS';
  bool _isLoadingAddon = true;
  bool _isProses = false;

  static const int _durasiHari = 7;

  @override
  void initState() {
    super.initState();
    _loadAddon();
  }

  Future<void> _loadAddon() async {
    final snap = await FirebaseFirestore.instance
        .collection('produk')
        .where('kategori_produk', isEqualTo: 'Aksesori')
        .where('status_produk', isEqualTo: 'Tersedia')
        .get();

    setState(() {
      _addonList = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      _isLoadingAddon = false;
    });
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) setState(() => _tanggalMulai = picked);
  }

  int get _totalHarga {
    final d = widget.produkData;
    final hargaPokok = widget.isPaket
        ? (d['harga_paket'] ?? 0) as int
        : (d['harga_sewa'] ?? 0) as int;

    int addonTotal = 0;
    for (final addon in _addonList) {
      if (_selectedAddonIds.contains(addon['id'])) {
        addonTotal += (addon['harga_sewa'] ?? 0) as int;
      }
    }

    return widget.isPaket ? hargaPokok + addonTotal
        : (hargaPokok * _durasiHari) + addonTotal;
  }

  String _formatHarga(int h) => h.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  String _formatTanggal(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  Future<void> _sewaSekarang() async {
    if (_tanggalMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal penyewaan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isProses = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final tanggalSelesai =
          _tanggalMulai!.add(const Duration(days: _durasiHari));

      // Generate no resi
      final countSnap = await FirebaseFirestore.instance
          .collection('sewa')
          .count()
          .get();
      final count   = (countSnap.count ?? 0) + 1;
      final noResi  = 'RLNSA${count.toString().padLeft(7, '0')}';

      // Simpan ke collection sewa
      final sewaRef = await FirebaseFirestore.instance
          .collection('sewa')
          .add({
        'user_id'          : uid,
        'produk_id'        : widget.isPaket ? null : widget.produkId,
        'paket_id'         : widget.isPaket ? widget.produkId : null,
        'addon_ids'        : _selectedAddonIds.toList(),
        'durasi_hari'      : _durasiHari,
        'tanggal_mulai'    : Timestamp.fromDate(_tanggalMulai!),
        'tanggal_selesai'  : Timestamp.fromDate(tanggalSelesai),
        'total'            : _totalHarga,
        'metode_pembayaran': _metodePembayaran,
        'status_pesanan'   : 'Menunggu',
        'no_resi'          : noResi,
        'created_at'       : FieldValue.serverTimestamp(),
        'updated_at'       : FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Tampilkan QRIS bottom sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => QrisBottomSheet(
          sewaId   : sewaRef.id,
          noResi   : noResi,
          total    : _totalHarga,
          produkData: widget.produkData,
          isPaket  : widget.isPaket,
          tanggalMulai  : _tanggalMulai!,
          tanggalSelesai: tanggalSelesai,
          addonIds : _selectedAddonIds.toList(),
          kondisi  : widget.kondisi,
          jumlahDisukai: widget.jumlahDisukai,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses pesanan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProses = false);
    }
  }

  ImageProvider? _getImage(String g) {
    if (g.isEmpty) return null;
    if (g.startsWith('data:image')) {
      return MemoryImage(base64Decode(g.split(',').last));
    }
    return NetworkImage(g);
  }

  @override
  Widget build(BuildContext context) {
    final d        = widget.produkData;
    final nama     = widget.isPaket ? (d['nama_paket'] ?? '') : (d['nama_produk'] ?? '');
    final deskripsi= widget.isPaket ? (d['deskripsi_paket'] ?? '') : (d['deskripsi_produk'] ?? '');
    final gambar   = widget.isPaket ? (d['gambar_paket'] ?? '') : (d['gambar_produk'] ?? '');
    final hargaPokok = widget.isPaket
        ? (d['harga_paket'] ?? 0) as int
        : (d['harga_sewa'] ?? 0) as int;
    final hargaStr = widget.isPaket
        ? 'Rp. ${_formatHarga(hargaPokok)}/paket'
        : 'Rp. ${_formatHarga(hargaPokok)}/hari';
    final imageProvider = _getImage(gambar);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Pemesanan',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Info produk ringkas ──
            Container(
              padding: const EdgeInsets.all(12),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 20),

            // ── Add-on ──
            const Text('Add-on',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _isLoadingAddon
                ? const Center(child: CircularProgressIndicator())
                : _addonList.isEmpty
                    ? Text('Tidak ada add-on tersedia',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500))
                    : SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _addonList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final addon   = _addonList[i];
                            final id      = addon['id'] as String;
                            final selected= _selectedAddonIds.contains(id);
                            final img     = _getImage(
                                addon['gambar_produk'] ?? '');
                            final hAddon  =
                                (addon['harga_sewa'] ?? 0) as int;

                            return GestureDetector(
                              onTap: () => setState(() {
                                if (selected) {
                                  _selectedAddonIds.remove(id);
                                } else {
                                  _selectedAddonIds.add(id);
                                }
                              }),
                              child: Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFE8EAF6)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF021427)
                                        : Colors.grey.shade200,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      child: img != null
                                          ? Image(
                                              image: img,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover)
                                          : Container(
                                              width: 44,
                                              height: 44,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 20,
                                                  color: Colors.grey)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      addon['nama_produk'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Rp. ${_formatHarga(hAddon)}',
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.black54),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 20),

            // ── Tanggal Penyewaan ──
            const Text('Tanggal Penyewaan',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTanggal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 10),
                    Text(
                      _tanggalMulai == null
                          ? 'Atur tanggal booking'
                          : 'Mulai: ${_formatTanggal(_tanggalMulai!)}  •  '
                              'Selesai: ${_formatTanggal(_tanggalMulai!.add(const Duration(days: _durasiHari)))}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _tanggalMulai == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Metode Pembayaran ──
            const Text('Metode Pembayaran',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _metodePembayaran,
                  items: const [
                    DropdownMenuItem(
                        value: 'QRIS', child: Text('QRIS')),
                  ],
                  onChanged: (v) =>
                      setState(() => _metodePembayaran = v ?? 'QRIS'),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom bar ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Harga total
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF021427),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Rp. ${_formatHarga(_totalHarga)}/hari',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProses ? null : _sewaSekarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF021427),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF021427)),
                  ),
                  elevation: 0,
                ),
                child: _isProses
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF021427)))
                    : const Text('Sewa sekarang',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
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