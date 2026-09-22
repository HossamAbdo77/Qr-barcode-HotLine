import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  Future<String> addProduct(Product product) async {
    final docRef = _productsRef.doc();
    await docRef.set(product.toMap());
    return docRef.id;
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<Product?> getProductByBarcode(String barcodeValue) async {
    var query = await _productsRef
        .where('barcode', isEqualTo: barcodeValue)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }

    query = await _productsRef
        .where('qrCode', isEqualTo: barcodeValue)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  Stream<List<Product>> getAllProducts() {
    return _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<bool> sellProduct(String productId, int quantityToSell) async {
    final docRef = _productsRef.doc(productId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentQty = data['quantity'] ?? 0;

      if (currentQty < quantityToSell) return false;

      transaction.update(docRef, {
        'quantity': currentQty - quantityToSell,
      });
      return true;
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  Future<bool> addStock(String productId, int quantityToAdd) async {
    final docRef = _productsRef.doc(productId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentQty = data['quantity'] ?? 0;

      transaction.update(docRef, {
        'quantity': currentQty + quantityToAdd,
      });
      return true;
    });
  }
}
