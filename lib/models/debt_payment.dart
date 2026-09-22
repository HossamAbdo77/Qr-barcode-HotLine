import 'package:cloud_firestore/cloud_firestore.dart';

class DebtPayment {
  final String id;
  final String debtId;
  final double amount;
  final String note;
  final DateTime date;

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'debtId': debtId,
      'amount': amount,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }

  factory DebtPayment.fromMap(String id, Map<String, dynamic> map) {
    return DebtPayment(
      id: id,
      debtId: map['debtId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
