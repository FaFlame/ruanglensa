// lib/pages/admin/admin_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _auth    = FirebaseAuth.instance;
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final _namaCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passCtrl     = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading   = false;
  String _photoUrl  = '';
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Load data profil dari Firestore ──────────────────────────────────────
  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _namaCtrl.text     = data['nama'] ?? '';
        _usernameCtrl.text = data['username'] ?? '';
        _photoUrl          = data['photoUrl'] ?? '';
      });
    }
  }

  // ── Pilih foto profil baru ────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newPhoto = File(picked.path));
  }

  // ── Simpan perubahan profil ───────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      String finalPhotoUrl = _photoUrl;

      // Upload foto baru kalau ada
      if (_newPhoto != null) {
        final ref = _storage.ref().child('users/$uid/profile.jpg');
        final upload = await ref.putFile(_newPhoto!);
        finalPhotoUrl = await upload.ref.getDownloadURL();
      }

      // Update Firestore
      final Map<String, dynamic> updateData = {
        'nama'    : _namaCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'photoUrl': finalPhotoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(uid).update(updateData);

      // Update password kalau diisi
      if (_passCtrl.text.trim().isNotEmpty) {
        await _auth.currentUser!.updatePassword(_passCtrl.text.trim());
        _passCtrl.clear();
      }

      if (mounted) {
        setState(() => _photoUrl = finalPhotoUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      // Arahkan ke halaman login
      // Ganti dengan route login kamu
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            const Text('Informasi Profile',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ── Foto profil ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _newPhoto != null
                            ? FileImage(_newPhoto!) as ImageProvider
                            : (_photoUrl.isNotEmpty
                                ? NetworkImage(_photoUrl)
                                : null),
                        child: (_newPhoto == null && _photoUrl.isEmpty)
                            ? const Icon(Icons.person,
                                size: 48, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF021427),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('ubah foto profil',
                      style: TextStyle(fontSize: 11, color: Colors.black38)),
                  const Text('hapus foto profil',
                      style: TextStyle(fontSize: 11, color: Colors.black38)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Form profil ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  const Text('Nama',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  _ProfileField(controller: _namaCtrl, hint: 'Nama lengkap'),
                  const SizedBox(height: 14),

                  // Username
                  const Text('Username',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  _ProfileField(controller: _usernameCtrl, hint: 'Username'),
                  const SizedBox(height: 14),

                  // Password
                  const Text('Password',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  _ProfileField(
                    controller: _passCtrl,
                    hint: '••••••••',
                    obscure: _obscurePass,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tombol Logout ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF021427)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Logout',
                    style: TextStyle(
                        color: Color(0xFF021427),
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Tombol Simpan ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF021427),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),

            // ── Logo & copyright ─────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', width: 100),
                  const SizedBox(height: 6),
                  const Text('©2026 - ruang lensa',
                      style: TextStyle(
                          fontSize: 11, color: Colors.black38)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input field profil ─────────────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;

  const _ProfileField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}