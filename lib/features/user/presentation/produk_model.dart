// lib/models/produk_model.dart


class Produk {
  final String id;
  final String namaProduk;
  final int hargaSewa;
  final int durasiSewa;       // dalam hari
  final String kategoriProduk; // "Kamera" | "Lensa"
  final String deskripsiProduk;
  final int kondisiProduk;    // 0-100
  final String statusProduk;  // "Tersedia" | "Tidak Tersedia"
  final String gambarProduk; // Base64 string, field: gambar_produk di Firestore

  const Produk({
    required this.id,
    required this.namaProduk,
    required this.hargaSewa,
    required this.durasiSewa,
    required this.kategoriProduk,
    required this.deskripsiProduk,
    required this.kondisiProduk,
    required this.statusProduk,
    required this.gambarProduk,
  });

  factory Produk.fromFirestore(Map<String, dynamic> data, String docId) {
    return Produk(
      id: docId,
      namaProduk: data['nama_produk'] ?? '',
      hargaSewa: (data['harga_sewa'] ?? 0).toInt(),
      durasiSewa: (data['durasi_sewa'] ?? 7).toInt(),
      kategoriProduk: data['kategori_produk'] ?? '',
      deskripsiProduk: data['deskripsi_produk'] ?? '',
      kondisiProduk: (data['kondisi_produk'] ?? 0).toInt(),
      statusProduk: data['status_produk'] ?? '',
      gambarProduk: data['gambar_produk'] ?? '',
    );
  }

  // Format harga untuk ditampilkan, contoh: "Rp. 429.000/7 hari"
  String get hargaFormatted {
    final hargaStr = hargaSewa.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $hargaStr/$durasiSewa hari';
  }
}

class Paket {
  final String id;
  final String namaPaket;
  final int hargaPaket;
  final String kategoriPaket; // "Paket Jasa"
  final String deskripsiPaket;
  final String statusPaket;   // "Tersedia" | "Tidak Tersedia"
  final String gambarPaket;   // Base64 string, field: gambar_paket di Firestore

  const Paket({
    required this.id,
    required this.namaPaket,
    required this.hargaPaket,
    required this.kategoriPaket,
    required this.deskripsiPaket,
    required this.statusPaket,
    required this.gambarPaket,
  });

  factory Paket.fromFirestore(Map<String, dynamic> data, String docId) {
    return Paket(
      id: docId,
      namaPaket: data['nama_paket'] ?? '',
      hargaPaket: (data['harga_paket'] ?? 0).toInt(),
      kategoriPaket: data['kategori_paket'] ?? '',
      deskripsiPaket: data['deskripsi_paket'] ?? '',
      statusPaket: data['status_paket'] ?? '',
      gambarPaket: data['gambar_paket'] ?? '',
    );
  }

  // Format harga untuk ditampilkan, contoh: "Rp. 143.000/paket"
  String get hargaFormatted {
    final hargaStr = hargaPaket.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $hargaStr/paket';
  }
}