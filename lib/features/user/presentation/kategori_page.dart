import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'produk_model.dart';
import 'produk_service.dart';
import 'detail_produk_page.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final String categoryImage;

  const CategoryPage({
    required this.categoryName,
    required this.categoryImage,
    super.key,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _service = ProdukService.instance;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  late Future<List<Produk>> _produkFuture;
  late Future<List<Paket>> _paketFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.categoryName == 'Kamera') {
      _produkFuture = _service.fetchKamera();
      _paketFuture = Future.value([]);
    } else if (widget.categoryName == 'Lensa') {
      _produkFuture = _service.fetchLensa();
      _paketFuture = Future.value([]);
    } else if (widget.categoryName == 'Paket') {
      _produkFuture = Future.value([]);
      _paketFuture = _service.fetchPaketJasa();
    } else if (widget.categoryName == 'Semua') {
      _produkFuture = _service.fetchSemuaProduk();
      _paketFuture = _service.fetchPaketJasa();
    } else {
      _produkFuture = Future.value([]);
      _paketFuture = Future.value([]);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loadData();
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  void _cari() {
    setState(() {
      _searchQuery = _searchCtrl.text.trim();
    });
  }

  List<Produk> _filterProduk(List<Produk> list) {
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((item) {
      return item.namaProduk.toLowerCase().contains(query) ||
          item.deskripsiProduk.toLowerCase().contains(query);
    }).toList();
  }

  List<Paket> _filterPaket(List<Paket> list) {
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((item) {
      return item.namaPaket.toLowerCase().contains(query) ||
          item.deskripsiPaket.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              // ── Section Produk ──────────────────────────────────────────
              if (widget.categoryName != 'Paket')
                FutureBuilder<List<Produk>>(
                  future: _produkFuture,
                  builder: (context, snapshot) {
                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildGridSkeleton();
                    }

                    // Error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat data: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final produkList = _filterProduk(snapshot.data ?? []);
                    
                    // Jika ada paket juga, tampilkan header
                    if (widget.categoryName == 'Semua' && produkList.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Produk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildProdukGrid(produkList),
                          const SizedBox(height: 24),
                        ],
                      );

                    } else if (produkList.isEmpty && widget.categoryName != 'Semua') {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada produk di kategori ini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return _buildProdukGrid(produkList);
                  },
                ),

              // ── Section Paket (hanya untuk Paket atau Semua) ─────────────
              if (widget.categoryName == 'Paket' || widget.categoryName == 'Semua')
                FutureBuilder<List<Paket>>(
                  future: _paketFuture,
                  builder: (context, snapshot) {
                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildGridSkeleton();
                    }

                    // Error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat data: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final paketList = _filterPaket(snapshot.data ?? []);

                    

                    // Empty state untuk kategori Paket saja
                    if (paketList.isEmpty && widget.categoryName == 'Paket') {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada paket di kategori ini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Jika kategori Semua dan tidak ada paket, jangan tampilkan
                    if (paketList.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Header untuk kategori Semua
                    if (widget.categoryName == 'Semua') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paket Jasa',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPaketGrid(paketList),
                        ],
                      );
                    }

                    return _buildPaketGrid(paketList);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProdukGrid(List<Produk> produkList) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: produkList
          .map((p) => _ProdukCardCategory(produk: p))
          .toList(),
    );
  }

  Widget _buildPaketGrid(List<Paket> paketList) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: paketList
          .map((p) => _PaketCardCategory(paket: p))
          .toList(),
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: List.generate(6, (_) => _SkeletonCard()),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (_) => _cari(),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Cari penyewaan foto & video',
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _cari,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: const Color(0xFF021427),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Cari',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _ProdukCardCategory extends StatelessWidget {
  final Produk produk;
  const _ProdukCardCategory({required this.produk});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (produk.gambarProduk.isNotEmpty) {
      imageBytes = base64Decode(produk.gambarProduk);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailProdukPage(
              produkId: produk.id,
              isPaket: false,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    width: double.infinity,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(height: 6),
          Text(
            produk.namaProduk,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            produk.hargaFormatted,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: double.infinity,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 28),
      );
}

class _PaketCardCategory extends StatelessWidget {
  final Paket paket;
  const _PaketCardCategory({required this.paket});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (paket.gambarPaket.isNotEmpty) {
      imageBytes = base64Decode(paket.gambarPaket);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailProdukPage(
              produkId: paket.id,
              isPaket: true,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    width: double.infinity,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(height: 6),
          Text(
            paket.namaPaket,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            paket.hargaFormatted,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: double.infinity,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 28),
      );
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 50,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
