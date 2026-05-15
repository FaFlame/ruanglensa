// lib/pages/admin/admin_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'admin_home_page.dart';
import 'admin_order_page.dart';
import 'admin_tambah_page.dart';
import 'admin_profile_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AdminHomePage(),
    AdminOrderPage(),
    AdminTambahPage(),
    AdminProfilePage(),
  ];

  void _onNavTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [
          // ── Konten halaman aktif ─────────────────────────────────────
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // ── Floating bottom nav ──────────────────────────────────────
          Positioned(
            bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: 370,
                    height: 69,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_navItems.length, (i) {
                        final isActive = i == _selectedIndex;
                        final item = _navItems[i];

                        return GestureDetector(
                          onTap: () => _onNavTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: isActive
                                ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                  )
                                : null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.icon, size: 22,
                                    color: isActive
                                        ? const Color(0xFF1C1C1E)
                                        : Colors.white),
                                if (isActive) ...[
                                  const SizedBox(height: 3),
                                  Text(item.label,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1C1C1E))),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded,           label: 'Beranda'),
    _NavItem(icon: Icons.receipt_long_rounded,   label: 'Order'),
    _NavItem(icon: Icons.add_circle_rounded,     label: 'Tambah'),
    _NavItem(icon: Icons.person_rounded,         label: 'Profile'),
  ];
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
