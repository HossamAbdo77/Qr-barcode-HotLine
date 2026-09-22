import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/debt.dart';
import '../models/financial_transaction.dart';
import '../services/financial_service.dart';
import '../services/translation_service.dart';

class DebtDetailScreen extends StatefulWidget {
  final Debt debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final FinancialService _service = FinancialService();
  late double _totalPaid;
  late double _remainingDebt;

  @override
  void initState() {
    super.initState();
    _totalPaid = widget.debt.totalPaid;
    _remainingDebt = widget.debt.remainingDebt;
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationService();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.debt.personName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              _MetricCard(
                label: t.total,
                value: widget.debt.totalDebt.toStringAsFixed(0),
                suffix: 'EGP',
                tone: _MetricTone.info,
              ),
              const SizedBox(width: 8),
              _MetricCard(
                label: t.paid,
                value: _totalPaid.toStringAsFixed(0),
                suffix: 'EGP',
                tone: _MetricTone.success,
              ),
              const SizedBox(width: 8),
              _MetricCard(
                label: t.remaining,
                value: _remainingDebt.toStringAsFixed(0),
                suffix: 'EGP',
                tone: _remainingDebt > 0 ? _MetricTone.warning : _MetricTone.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showPayDebtDialog(context),
                  icon: const Icon(Icons.payment, size: 18),
                  label: Text(t.payDebt, style: GoogleFonts.ibmPlexSansArabic()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMoreDebtDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t.addDebt, style: GoogleFonts.ibmPlexSansArabic()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            t.history,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<FinancialTransaction>>(
            stream: _service.getTransactionsForPerson(widget.debt.personName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final transactions = snapshot.data ?? [];
              if (transactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      t.noHistory,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isPayment = tx.type == 'payment';
                    final isAdditionalDebt = tx.note.startsWith('Additional debt');

                    String label;
                    IconData icon;
                    Color iconColor;
                    Color bgColor;

                    if (isPayment) {
                      label = t.paymentLabel;
                      icon = Icons.check;
                      iconColor = AppColors.success;
                      bgColor = AppColors.successSoft;
                    } else if (isAdditionalDebt) {
                      label = t.extraDebtLabel;
                      icon = Icons.add;
                      iconColor = AppColors.warning;
                      bgColor = AppColors.warningSoft;
                    } else {
                      label = t.saleDebtLabel;
                      icon = Icons.shopping_cart_outlined;
                      iconColor = AppColors.info;
                      bgColor = AppColors.infoSoft;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 17),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tx.note,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isPayment ? '-' : '+'}${tx.amount.toStringAsFixed(0)} EGP',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isPayment ? AppColors.success : AppColors.warning,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd/MM/yyyy').format(tx.date),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(BuildContext context) {
    final amountController = TextEditingController();
    final t = TranslationService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.payDebt, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.current}: ${_remainingDebt.toStringAsFixed(0)} EGP',
              style: GoogleFonts.ibmPlexSansArabic(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.paymentAmount,
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                hintText: t.enterAmount,
                hintStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel, style: GoogleFonts.ibmPlexSansArabic()),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || amount > _remainingDebt) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.invalidAmount)),
                  );
                }
                return;
              }

              await _service.payDebt(widget.debt.id, amount, widget.debt.personName);

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                setState(() {
                  _totalPaid += amount;
                  _remainingDebt -= amount;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("${t.pay} ${amount.toStringAsFixed(0)} EGP")),
                );
              }
            },
            child: Text(t.pay, style: GoogleFonts.ibmPlexSansArabic()),
          ),
        ],
      ),
    );
  }

  void _showAddMoreDebtDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final t = TranslationService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.addMoreDebt, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.current}: ${_remainingDebt.toStringAsFixed(0)} EGP',
              style: GoogleFonts.ibmPlexSansArabic(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.amountToAdd,
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                hintText: t.enterAmount,
                hintStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: t.noteOptional,
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                hintText: t.extraItemsLateFee,
                hintStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel, style: GoogleFonts.ibmPlexSansArabic()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.invalidAmount)),
                  );
                }
                return;
              }

              final note = noteController.text.trim();
              final txNote = note.isNotEmpty
                  ? '${widget.debt.personName} - $note'
                  : widget.debt.personName;

              await _service.addMoreDebt(widget.debt.id, amount, txNote);

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                setState(() {
                  _remainingDebt += amount;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("${t.add} ${amount.toStringAsFixed(0)} EGP")),
                );
              }
            },
            child: Text(t.add, style: GoogleFonts.ibmPlexSansArabic()),
          ),
        ],
      ),
    );
  }
}

enum _MetricTone { success, info, warning }

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final _MetricTone tone;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.tone,
  });

  Color get _toneColor {
    switch (tone) {
      case _MetricTone.success:
        return AppColors.success;
      case _MetricTone.info:
        return AppColors.info;
      case _MetricTone.warning:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _toneColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              suffix,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 10,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
