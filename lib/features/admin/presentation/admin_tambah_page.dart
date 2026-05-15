// lib/pages/admin/admin_tambah_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'admin_service.dart';

// Pastikan tambahkan di pubspec.yaml:
//   image_picker: ^1.x.x

class AdminTambahPage extends StatefulWidget {
  const AdminTambahPage({super.key});

  @override
  State<AdminTambahPage> createState() => _AdminTambahPageState();
}

class _AdminTambahPageState extends State<AdminTambahPage> {
  // Tab: 0 = Produk, 1 = Paket
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Tambah Produk',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // ── Tab Produk / Paket ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TabButton(
                  label: 'Produk',
                  isActive: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 10),
                _TabButton(
                  label: 'Paket',
                  isActive: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: _tabIndex == 0
                ? const _FormProduk()
                : const _FormPaket(),
          ),
        ],
      ),
    );
  }
}

// ── Tab button ─────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF021427) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Tambah Produk
// ─────────────────────────────────────────────────────────────────────────────
class _FormProduk extends StatefulWidget {
  const _FormProduk();

  @override
  State<_FormProduk> createState() => _FormProdukState();
}

class _FormProdukState extends State<_FormProduk> {
  final _formKey  = GlobalKey<FormState>();
  final _nama     = TextEditingController();
  final _harga    = TextEditingController();
  final _durasi   = TextEditingController();
  final _deskripsi = TextEditingController();
  final _kondisi  = TextEditingController();

  String _kategori = 'Kamera';
  String _status   = 'Tersedia';
  Uint8List? _imageBytes;
  bool _isLoading  = false;

  final List<String> _kategoriOptions = ['Kamera', 'Lensa'];
  final List<String> _statusOptions   = ['Tersedia', 'Tidak Tersedia'];

  @override
  void dispose() {
    _nama.dispose(); _harga.dispose(); _durasi.dispose();
    _deskripsi.dispose(); _kondisi.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AdminService.instance.tambahProduk(
        namaProduk     : _nama.text.trim(),
        hargaSewa      : int.parse(_harga.text.trim()),
        durasiSewa     : int.parse(_durasi.text.trim()),
        kategoriProduk : _kategori,
        deskripsiProduk: _deskripsi.text.trim(),
        kondisiProduk  : int.parse(_kondisi.text.trim()),
        statusProduk   : _status,
        imageBytes     : _imageBytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
        _formKey.currentState!.reset();
        setState(() => _imageBytes = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Pilih gambar
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 140),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 36, color: Colors.grey),
                          SizedBox(height: 6),
                          Text('Pilih Foto',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            _Field(controller: _nama,      label: 'Nama Produk'),
            _Field(controller: _harga,     label: 'Harga Sewa (angka)', isNumber: true),
            _Field(controller: _durasi,    label: 'Durasi Sewa (hari)', isNumber: true),
            _Field(controller: _deskripsi, label: 'Deskripsi', maxLines: 3),
            _Field(controller: _kondisi,   label: 'Kondisi (0-100)', isNumber: true),

            // Dropdown Kategori
            _Dropdown(
              label: 'Kategori',
              value: _kategori,
              items: _kategoriOptions,
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),

            // Dropdown Status
            _Dropdown(
              label: 'Status',
              value: _status,
              items: _statusOptions,
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 20),

            // Tombol simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF021427),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Produk',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Tambah Paket
// ─────────────────────────────────────────────────────────────────────────────
class _FormPaket extends StatefulWidget {
  const _FormPaket();

  @override
  State<_FormPaket> createState() => _FormPaketState();
}

class _FormPaketState extends State<_FormPaket> {
  final _formKey   = GlobalKey<FormState>();
  final _nama      = TextEditingController();
  final _harga     = TextEditingController();
  final _deskripsi = TextEditingController();

  final String _kategori = 'Paket Jasa';
  String _status   = 'Tersedia';
  Uint8List? _imageBytes;
  bool _isLoading  = false;

  final List<String> _statusOptions = ['Tersedia', 'Tidak Tersedia'];

  @override
  void dispose() {
    _nama.dispose(); _harga.dispose(); _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AdminService.instance.tambahPaket(
        namaPaket     : _nama.text.trim(),
        hargaPaket    : int.parse(_harga.text.trim()),
        kategoriPaket : _kategori,
        deskripsiPaket: _deskripsi.text.trim(),
        statusPaket   : _status,
        imageBytes    : _imageBytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paket berhasil ditambahkan!')),
        );
        _formKey.currentState!.reset();
        setState(() => _imageBytes = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 140),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 36, color: Colors.grey),
                          SizedBox(height: 6),
                          Text('Pilih Foto',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            _Field(controller: _nama,      label: 'Nama Paket'),
            _Field(controller: _harga,     label: 'Harga Paket (angka)', isNumber: true),
            _Field(controller: _deskripsi, label: 'Deskripsi', maxLines: 3),

            _Dropdown(
              label: 'Status',
              value: _status,
              items: _statusOptions,
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF021427),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Paket',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumber;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    this.isNumber = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}