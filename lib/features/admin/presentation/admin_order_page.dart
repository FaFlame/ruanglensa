// lib/pages/admin/admin_order_page.dart

import 'package:flutter/material.dart';
import 'admin_service.dart';
import 'sewa_model.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
  String _filterStatus = 'Semua';

  final List<String> _tabs = [
    'Semua', 'Pesanan Baru', 'Dalam Proses', 'Waktu Berakhir'
  ];

  // Map label tab ke nilai status_pesanan di Firestore
  final Map<String, String?> _statusMap = {
    'Semua'         : null,
    'Pesanan Baru'  : 'Menunggu',
    'Dalam Proses'  : 'Diproses',
    'Waktu Berakhir': 'Selesai',
  };

  late Future<List<Sewa>> _sewaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final status = _statusMap[_filterStatus];
    if (status == null) {
      _sewaFuture = AdminService.instance.fetchSemuaPesanan();
    } else {
      _sewaFuture = AdminService.instance.fetchPesananByStatus(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text('Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          // ── Filter tab 2x2 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _FilterChip(
                      label: _tabs[0],
                      isActive: _filterStatus == _tabs[0],
                      onTap: () => _setFilter(_tabs[0]),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _tabs[1],
                      isActive: _filterStatus == _tabs[1],
                      onTap: () => _setFilter(_tabs[1]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FilterChip(
                      label: _tabs[2],
                      isActive: _filterStatus == _tabs[2],
                      onTap: () => _setFilter(_tabs[2]),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _tabs[3],
                      isActive: _filterStatus == _tabs[3],
                      onTap: () => _setFilter(_tabs[3]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Daftar pesanan ────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Sewa>>(
              future: _sewaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada pesanan.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() => _loadData()),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OrderCard(sewa: list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setFilter(String status) {
    setState(() {
      _filterStatus = status;
      _loadData();
    });
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF021427) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Kartu pesanan ──────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Sewa sewa;
  const _OrderCard({required this.sewa});

  Color _badgeColor(int sisaHari) {
    if (sisaHari <= 3) return Colors.red.shade400;
    if (sisaHari <= 7) return Colors.green.shade500;
    return Colors.blue.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final sisaHari = sewa.sisaHari;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ID + badge sisa hari ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${sewa.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor(sisaHari),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sisaHari > 0 ? 'Baru - $sisaHari Hari lagi' : 'Waktu Habis',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Detail pesanan ──────────────────────────────────────────
          _Row(label: 'user',           value: sewa.userId),
          _Row(label: 'Order',          value: sewa.produkId),
          _Row(label: 'Pembayaran',     value: sewa.metodePembayaran),
          _Row(label: 'Tanggal Mulai',  value: Sewa.formatTanggal(sewa.tanggalMulai)),
          _Row(label: 'Tanggal Selesai',value: Sewa.formatTanggal(sewa.tanggalSelesai)),
          _Row(label: 'Total',          value: sewa.totalFormatted),
          const SizedBox(height: 10),

          // ── Tombol update status ────────────────────────────────────
          Row(
            children: [
              _StatusButton(
                label: 'Diproses',
                isActive: sewa.statusPesanan == 'Diproses',
                onTap: () => _updateStatus(context, 'Diproses'),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: 'Selesai',
                isActive: sewa.statusPesanan == 'Selesai',
                onTap: () => _updateStatus(context, 'Selesai'),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: 'Batal',
                isActive: sewa.statusPesanan == 'Dibatalkan',
                color: Colors.red.shade400,
                onTap: () => _updateStatus(context, 'Dibatalkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, String status) async {
    await AdminService.instance.updateStatusPesanan(sewa.id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah ke $status')),
      );
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _StatusButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFF021427);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black54)),
          ),
        ),
      ),
    );
  }
}