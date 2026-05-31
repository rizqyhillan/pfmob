import 'product.dart';

typedef ShopProduct = Product;

class ShopCartItem {
  final int id;
  final int idBarang;
  final String namaBarang;
  final String kategori;
  final String? imageUrl;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final int stok;
  final bool tersedia;

  ShopCartItem({
    required this.id,
    required this.idBarang,
    required this.namaBarang,
    required this.kategori,
    this.imageUrl,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    required this.stok,
    required this.tersedia,
  });

  factory ShopCartItem.fromJson(Map<String, dynamic> json) => ShopCartItem(
        id: json['id'] ?? 0,
        idBarang: json['id_barang'] ?? 0,
        namaBarang: json['nama_barang'] ?? '-',
        kategori: json['kategori'] ?? '-',
        imageUrl: json['image_url'],
        jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
        hargaSatuan: double.tryParse(json['harga_satuan'].toString()) ?? 0,
        subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
        stok: int.tryParse(json['stok'].toString()) ?? 0,
        tersedia: json['tersedia'] == true,
      );
}

class ShopCart {
  final int id;
  final String status;
  final List<ShopCartItem> items;
  final int totalItem;
  final double totalHarga;

  ShopCart({
    required this.id,
    required this.status,
    required this.items,
    required this.totalItem,
    required this.totalHarga,
  });

  factory ShopCart.fromJson(Map<String, dynamic> json) => ShopCart(
        id: json['id'] ?? 0,
        status: json['status'] ?? '-',
        items: ((json['items'] ?? []) as List)
            .map((e) => ShopCartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalItem: int.tryParse(json['total_item'].toString()) ?? 0,
        totalHarga: double.tryParse(json['total_harga'].toString()) ?? 0,
      );
}
