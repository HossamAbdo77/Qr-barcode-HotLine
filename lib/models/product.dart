import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String barcode;
  final String qrCode;
  final String type;
  final double price;
  final double wholesalePrice;
  final int quantity;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.qrCode,
    required this.type,
    required this.price,
    required this.quantity,
    required this.createdAt,
    this.wholesalePrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'qrCode': qrCode,
      'type': type,
      'price': price,
      'wholesalePrice': wholesalePrice,
      'quantity': quantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      qrCode: map['qrCode'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      wholesalePrice: (map['wholesalePrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
