import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_info_page.dart';
import 'user_level_page.dart';
// import 'keranjang_page.dart';
// import 'histori_pesanan_page.dart';
// import 'disukai_page.dart';
import '../../auth/presentation/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (mounted) {
      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    }
  }

  String _getLevelName(int points) {
    if (points <= 1000) return 'Level 1 - Biasa';
    if (points <= 2000) return 'Level 2 - Langganan';
    return 'Level 3 - Premium';
  }

  int _getLevelMax(int points) {
    if (points <= 1000) return 1000;
    if (points <= 2000) return 2000;
    return 3000;
  }

  int _getLevelMin(int points) {
    if (points <= 1000) return 0;
    if (points <= 2000) return 1001;
    return 2001;
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPageClean()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final nama = _userData?['nama'] ?? '';
    final bio = _userData?['bio'] ?? '';
    final fotoProfil = _userData?['foto_profil'] ?? '';
    final levelPoints =
        int.tryParse((_userData?['level_points'] ?? 0).toString()) ?? 0;
    final levelName = _getLevelName(levelPoints);
    final levelMax = _getLevelMax(levelPoints);
    final levelMin = _getLevelMin(levelPoints);
    final progress = (levelPoints - levelMin) / (levelMax - levelMin);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Informasi Pengguna',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          // ── Card Profil (foto + nama + bio) ──
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserInfoPage()),
              );
              _loadUserData(); // refresh setelah balik dari edit
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: fotoProfil.isNotEmpty
                        ? NetworkImage(fotoProfil)
                        : null,
                    child: fotoProfil.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 34,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama.isNotEmpty ? nama : 'Nama belum diisi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bio.isNotEmpty ? bio : 'Bio belum diisi',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Card Level ──
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserLevelPage(userData: _userData!),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF021427),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$levelPoints/$levelMax',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 3 tombol shortcut ──
          Row(
            children: [
              _shortcutBtn(
                icon: Icons.shopping_cart_outlined,
                label: 'Keranjang',
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const KeranjangPage()));
                },
              ),
              const SizedBox(width: 10),
              _shortcutBtn(
                icon: Icons.history_rounded,
                label: 'Histori Pesanan',
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriPesananPage()));
                },
              ),
              const SizedBox(width: 10),
              _shortcutBtn(
                icon: Icons.favorite_border_rounded,
                label: 'Disukai',
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const DisukaiPage()));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Bantuan & Dukungan ──
          _menuItem(label: 'Bantuan & Dukungan', onTap: () {}),
          const SizedBox(height: 8),

          // ── Logout ──
          _menuItem(label: 'Logout', onTap: _logout, isDestructive: true),
          const SizedBox(height: 24),

          // ── Footer branding ──
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', width: 32),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RUANG LENSA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Sewa mudah, Hasil mewah',
                          style: TextStyle(fontSize: 10, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '© 2026 · ruang.lensa',
                  style: TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcutBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF021427)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
