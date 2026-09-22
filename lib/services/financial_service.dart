import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_transaction.dart';
import '../models/debt.dart';
import '../models/debt_payment.dart';

class FinancialService {
  final _transactionsRef =
      FirebaseFirestore.instance.collection('financial_transactions');
  final _debtsRef = FirebaseFirestore.instance.collection('debts');
  final _paymentsRef = FirebaseFirestore.instance.collection('debt_payments');

  Future<void> addTransaction(FinancialTransaction transaction) async {
    await _transactionsRef.doc().set(transaction.toMap());
  }

  Stream<List<FinancialTransaction>> getAllTransactions() {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                FinancialTransaction.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<FinancialTransaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                FinancialTransaction.fromMap(doc.id, doc.data()))
            .where((t) =>
                t.date.isAfter(start.subtract(const Duration(days: 1))) &&
                t.date.isBefore(end.add(const Duration(days: 1))))
            .toList());
  }

  Future<double> getTotalSales() async {
    final snapshot = await _transactionsRef.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'sale' || data['type'] == 'paid') {
        total += (data['amount'] ?? 0).toDouble();
      }
    }
    return total;
  }

  Future<double> getTotalPaid() async {
    final snapshot = await _transactionsRef.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'paid') {
        total += (data['amount'] ?? 0).toDouble();
      }
    }
    return total;
  }

  Future<double> getTotalDebt() async {
    final snapshot = await _debtsRef.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['remainingDebt'] ?? 0).toDouble();
    }
    return total;
  }

  Future<String> addDebt(Debt debt) async {
    final docRef = _debtsRef.doc();
    await docRef.set(debt.toMap());
    return docRef.id;
  }

  Future<void> addMoreDebt(String debtId, double additionalAmount, String note) async {
    final docRef = _debtsRef.doc(debtId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentDebt = (data['totalDebt'] ?? 0).toDouble();
      final remaining = (data['remainingDebt'] ?? 0).toDouble();

      transaction.update(docRef, {
        'totalDebt': currentDebt + additionalAmount,
        'remainingDebt': remaining + additionalAmount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });

    await addTransaction(FinancialTransaction(
      id: '',
      amount: additionalAmount,
      type: 'sale',
      note: note.isNotEmpty ? 'Additional debt - $note' : 'Additional debt',
      date: DateTime.now(),
    ));
  }

  Stream<List<Debt>> getAllDebts() {
    return _debtsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Debt.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<Debt?> getDebt(String debtId) async {
    final doc = await _debtsRef.doc(debtId).get();
    if (!doc.exists) return null;
    return Debt.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> payDebt(String debtId, double amount, String note) async {
    final docRef = _debtsRef.doc(debtId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentPaid = (data['totalPaid'] ?? 0).toDouble();
      final remaining = (data['remainingDebt'] ?? 0).toDouble();

      if (amount > remaining) return;

      transaction.update(docRef, {
        'totalPaid': currentPaid + amount,
        'remainingDebt': remaining - amount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });

    await _paymentsRef.doc().set(
      DebtPayment(
        id: '',
        debtId: debtId,
        amount: amount,
        note: note,
        date: DateTime.now(),
      ).toMap(),
    );

    await addTransaction(FinancialTransaction(
      id: '',
      amount: amount,
      type: 'payment',
      note: note.isNotEmpty ? 'Debt payment - $note' : 'Debt payment',
      date: DateTime.now(),
    ));
  }

  Future<void> recordRefund(double amount, String productName, int quantity, double unitPrice) async {
    await addTransaction(FinancialTransaction(
      id: '',
      amount: amount,
      type: 'refund',
      note: '$productName x$quantity (Adj)',
      date: DateTime.now(),
      unitPrice: unitPrice,
      quantity: quantity,
    ));
  }

  Stream<List<DebtPayment>> getPaymentsForDebt(String debtId) {
    return _paymentsRef
        .where('debtId', isEqualTo: debtId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DebtPayment.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<FinancialTransaction>> getTransactionsForPerson(String personName) {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromMap(doc.id, doc.data()))
            .where((t) => t.note.contains(personName))
            .toList());
  }

  Future<void> recordSale(double amount, String productName, int quantity, double unitPrice) async {
    await addTransaction(FinancialTransaction(
      id: '',
      amount: amount,
      type: 'sale',
      note: '$productName x$quantity',
      date: DateTime.now(),
      unitPrice: unitPrice,
      quantity: quantity,
    ));
  }

  Future<void> addSaleAsDebt(double amount, String productName, int quantity,
      String personName, double unitPrice) async {
    final now = DateTime.now();
    final docRef = _debtsRef.doc();
    await docRef.set(Debt(
      id: '',
      personName: personName,
      totalDebt: amount,
      totalPaid: 0,
      remainingDebt: amount,
      createdAt: now,
      updatedAt: now,
    ).toMap());

    await addTransaction(FinancialTransaction(
      id: '',
      amount: amount,
      type: 'sale',
      note: '$productName x$quantity (Debt - $personName)',
      date: now,
      unitPrice: unitPrice,
      quantity: quantity,
    ));
  }

  Future<void> recordPurchase(double amount, String productName, int quantity, double unitPrice) async {
    await addTransaction(FinancialTransaction(
      id: '',
      amount: amount,
      type: 'purchase',
      note: '$productName x$quantity',
      date: DateTime.now(),
      unitPrice: unitPrice,
      quantity: quantity,
    ));
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }

  Future<void> deleteTransactionsByProductName(String productName) async {
    final snapshot = await _transactionsRef
        .where('type', isEqualTo: 'purchase')
        .get();
    for (var doc in snapshot.docs) {
      final note = (doc.data()['note'] ?? '').toString();
      if (note.startsWith(productName)) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> deleteDebt(String debtId) async {
    final paymentsSnapshot = await _paymentsRef
        .where('debtId', isEqualTo: debtId)
        .get();
    for (var doc in paymentsSnapshot.docs) {
      await doc.reference.delete();
    }

    final debtDoc = await _debtsRef.doc(debtId).get();
    if (debtDoc.exists) {
      final data = debtDoc.data() as Map<String, dynamic>;
      final personName = (data['personName'] ?? '').toString();

      final txSnapshot = await _transactionsRef
          .where('type', isEqualTo: 'sale')
          .get();
      for (var doc in txSnapshot.docs) {
        final note = (doc.data()['note'] ?? '').toString();
        if (note.contains('(Debt - $personName)') || note.contains(personName)) {
          await doc.reference.delete();
        }
      }

      await _debtsRef.doc(debtId).delete();
    }
  }

  Stream<double> getTotalRemainingDebt() {
    return _debtsRef.snapshots().map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['remainingDebt'] ?? 0).toDouble();
      }
      return total;
    });
  }
}
