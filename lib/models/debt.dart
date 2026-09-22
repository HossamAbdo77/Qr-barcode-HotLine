import 'package:cloud_firestore/cloud_firestore.dart';

class Debt {
  final String id;
  final String personName;
  final double totalDebt;
  final double totalPaid;
  final double remainingDebt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.personName,
    required this.totalDebt,
    required this.totalPaid,
    required this.remainingDebt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'totalDebt': totalDebt,
      'totalPaid': totalPaid,
      'remainingDebt': remainingDebt,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Debt.fromMap(String id, Map<String, dynamic> map) {
    return Debt(
      id: id,
      personName: map['personName'] ?? '',
      totalDebt: (map['totalDebt'] ?? 0).toDouble(),
      totalPaid: (map['totalPaid'] ?? 0).toDouble(),
      remainingDebt: (map['remainingDebt'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
