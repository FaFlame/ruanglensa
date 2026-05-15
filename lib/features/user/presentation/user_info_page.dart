import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _namaCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _bioCtrl      = TextEditingController();
  final _noTelpCtrl   = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _alamatCtrl   = TextEditingController();

  bool _isLoading   = true;
  bool _isSaving    = false;
  bool _obscurePass = true;

  DateTime? _tglLahir;
  String _fotoProfil = ''; // base64 string atau kosong

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};
    setState(() {
      _namaCtrl.text     = data['nama']     ?? '';
      _usernameCtrl.text = data['username'] ?? '';
      _bioCtrl.text      = data['bio']      ?? '';
      _noTelpCtrl.text   = data['no_telp']  ?? '';
      _emailCtrl.text    = data['email']    ?? '';
      _alamatCtrl.text   = data['alamat']   ?? '';
      _fotoProfil        = data['foto_profil'] ?? '';

      final tgl = data['tgl_lahir'];
      if (tgl != null && tgl is Timestamp) {
        _tglLahir = tgl.toDate();
      }
      _isLoading = false;
    });
  }

  // ─────────────────────────────────────────────
  //  FOTO PROFIL — pick & convert to Base64
  // ─────────────────────────────────────────────
  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70, // compress supaya tidak terlalu besar
    );

    if (picked == null) return;

    final Uint8List bytes = await picked.readAsBytes();
    final String base64Str = base64Encode(bytes);
    final String dataUrl = 'data:image/jpeg;base64,$base64Str';

    // Simpan langsung ke Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'foto_profil': dataUrl,
        'updated_at' : FieldValue.serverTimestamp(),
      });
      setState(() => _fotoProfil = dataUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _hapusFoto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'foto_profil': '', 'updated_at': FieldValue.serverTimestamp()});
    setState(() => _fotoProfil = '');
  }

  // ─────────────────────────────────────────────
  //  Build avatar — support Base64 & NetworkImage
  // ─────────────────────────────────────────────
  ImageProvider? _getImageProvider() {
    if (_fotoProfil.isEmpty) return null;
    if (_fotoProfil.startsWith('data:image')) {
      // Base64
      final base64Str = _fotoProfil.split(',').last;
      return MemoryImage(base64Decode(base64Str));
    }
    // URL biasa
    return NetworkImage(_fotoProfil);
  }

  // ─────────────────────────────────────────────
  //  SAVE DATA
  // ─────────────────────────────────────────────
  Future<void> _saveData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> updateData = {
        'nama'       : _namaCtrl.text.trim(),
        'username'   : _usernameCtrl.text.trim(),
        'bio'        : _bioCtrl.text.trim(),
        'no_telp'    : _noTelpCtrl.text.trim(),
        'alamat'     : _alamatCtrl.text.trim(),
        'updated_at' : FieldValue.serverTimestamp(),
      };

      if (_tglLahir != null) {
        updateData['tgl_lahir'] = Timestamp.fromDate(_tglLahir!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);

      // Update password jika diisi
      if (_passwordCtrl.text.trim().isNotEmpty) {
        await FirebaseAuth.instance.currentUser
            ?.updatePassword(_passwordCtrl.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickTglLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) setState(() => _tglLahir = picked);
  }

  String _formatTgl(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year}';
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffixIcon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: const UnderlineInputBorder(),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _bioCtrl.dispose();
    _noTelpCtrl.dispose();
    _emailCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final imageProvider = _getImageProvider();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Informasi Pengguna',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // ── Foto Profil ──
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person,
                              size: 38, color: Colors.white)
                          : null,
                    ),
                    if (_isSaving)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : _pickFoto,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Ubah foto profil',
                          style: TextStyle(fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: _isSaving || _fotoProfil.isEmpty
                          ? null
                          : _hapusFoto,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Hapus foto profil',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Form fields ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildField(label: 'Nama', controller: _namaCtrl),
                  const SizedBox(height: 14),
                  _buildField(label: 'Username', controller: _usernameCtrl),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscure: _obscurePass,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildField(label: 'Bio', controller: _bioCtrl),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'No. Telepon',
                    controller: _noTelpCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Email',
                    controller: _emailCtrl,
                    readOnly: true,
                  ),
                  const SizedBox(height: 14),
                  _buildField(label: 'Alamat', controller: _alamatCtrl),
                  const SizedBox(height: 14),

                  // ── Tanggal Lahir ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal Lahir',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                      GestureDetector(
                        onTap: _pickTglLahir,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(
                                text: _formatTgl(_tglLahir)),
                            readOnly: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 8),
                              border: UnderlineInputBorder(),
                              suffixIcon:
                                  Icon(Icons.calendar_today, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Tombol Simpan ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF021427),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Simpan',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}