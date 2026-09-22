import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialTransaction {
  final String id;
  final double amount;
  final String type;
  final String note;
  final DateTime date;
  final double? unitPrice;
  final int? quantity;

  FinancialTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
    this.unitPrice,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'note': note,
      'date': Timestamp.fromDate(date),
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (quantity != null) 'quantity': quantity,
    };
  }

  factory FinancialTransaction.fromMap(String id, Map<String, dynamic> map) {
    return FinancialTransaction(
      id: id,
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unitPrice: map['unitPrice'] != null ? (map['unitPrice'] as num).toDouble() : null,
      quantity: map['quantity'] != null ? (map['quantity'] as num).toInt() : null,
    );
  }
}
