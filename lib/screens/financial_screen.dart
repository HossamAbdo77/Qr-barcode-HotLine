import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/financial_transaction.dart';
import '../services/financial_service.dart';
import '../services/translation_service.dart';

enum DateFilter { today, week, month, custom }

class FinancialScreen extends StatefulWidget {
  final FinancialService _service = FinancialService();

  FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  DateFilter _selectedFilter = DateFilter.month;
  DateTime? _customStart;
  DateTime? _customEnd;
  String _selectedCategoryKey = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _translation = TranslationService();

  static const List<String> _categoryKeys = ['all', 'sale', 'purchase', 'debt', 'payment', 'adj'];

  @override
  void initState() {
    super.initState();
    _translation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _translation.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<FinancialTransaction>> _getTransactions() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return widget._service.getTransactionsByDateRange(start, end);
      case DateFilter.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final startDay = DateTime(start.year, start.month, start.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return widget._service.getTransactionsByDateRange(startDay, end);
      case DateFilter.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return widget._service.getTransactionsByDateRange(start, end);
      case DateFilter.custom:
        if (_customStart != null && _customEnd != null) {
          final end = DateTime(
              _customEnd!.year, _customEnd!.month, _customEnd!.day, 23, 59, 59);
          return widget._service.getTransactionsByDateRange(_customStart!, end);
        }
        return widget._service.getAllTransactions();
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final start = await showDatePicker(
      context: context,
      initialDate: _customStart ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.primaryForeground,
              surface: AppColors.card,
              onSurface: AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (start == null || !mounted) return;

    final end = await showDatePicker(
      context: context,
      initialDate: _customEnd ?? start,
      firstDate: start,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.primaryForeground,
              surface: AppColors.card,
              onSurface: AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (end == null || !mounted) return;

    setState(() {
      _customStart = start;
      _customEnd = end;
      _selectedFilter = DateFilter.custom;
    });
  }

  String _getFilterLabel() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        return DateFormat('dd MMM yyyy').format(now);
      case DateFilter.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(now)}';
      case DateFilter.month:
        return DateFormat('MMMM yyyy').format(now);
      case DateFilter.custom:
        if (_customStart != null && _customEnd != null) {
          return '${DateFormat('dd MMM').format(_customStart!)} - ${DateFormat('dd MMM').format(_customEnd!)}';
        }
        return TranslationService().allTime;
    }
  }

  String _getCategoryLabel(String key) {
    final t = TranslationService();
    switch (key) {
      case 'all': return t.all;
      case 'sale': return t.sale;
      case 'purchase': return t.purchase;
      case 'debt': return t.debt;
      case 'payment': return t.payment;
      case 'adj': return t.adj;
      default: return key;
    }
  }

  IconData _getCategoryIcon(String key) {
    switch (key) {
      case 'all': return Icons.grid_view;
      case 'sale': return Icons.trending_up;
      case 'purchase': return Icons.shopping_cart_outlined;
      case 'debt': return Icons.person_outline;
      case 'payment': return Icons.payment;
      case 'adj': return Icons.edit_note;
      default: return Icons.help_outline;
    }
  }

  Color _getCategoryColor(String key) {
    switch (key) {
      case 'all': return AppColors.mutedForeground;
      case 'sale': return AppColors.success;
      case 'purchase': return AppColors.destructive;
      case 'debt': return AppColors.warning;
      case 'payment': return AppColors.info;
      case 'adj': return AppColors.mutedForeground;
      default: return AppColors.mutedForeground;
    }
  }

  bool _filterByCategory(FinancialTransaction t) {
    switch (_selectedCategoryKey) {
      case 'all': return true;
      case 'sale': return t.type == 'sale' && !t.note.contains('(Debt -');
      case 'debt': return t.type == 'sale' && t.note.contains('(Debt -');
      case 'purchase': return t.type == 'purchase';
      case 'payment': return t.type == 'payment';
      case 'adj': return t.type == 'refund';
      default: return true;
    }
  }

  String _getTypeLabel(FinancialTransaction t) {
    final tr = TranslationService();
    if (t.type == 'refund') return tr.adj;
    if (t.type == 'sale') return t.note.contains('(Debt -') ? tr.debt : tr.sale;
    if (t.type == 'purchase') return tr.purchase;
    if (t.type == 'payment') return tr.payment;
    return '';
  }

  Color _getTypeColor(String typeLabel) {
    final t = TranslationService();
    if (typeLabel == t.sale) return AppColors.success;
    if (typeLabel == t.debt) return AppColors.warning;
    if (typeLabel == t.purchase) return AppColors.destructive;
    if (typeLabel == t.payment) return AppColors.info;
    if (typeLabel == t.adj) return AppColors.mutedForeground;
    return AppColors.mutedForeground;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;
    final t = TranslationService();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.finance,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: isSmallScreen ? 20 : 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFilterLabel(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final labels = [t.today, t.week, t.month, t.custom];
                final filters = [DateFilter.today, DateFilter.week, DateFilter.month, DateFilter.custom];
                final selected = _selectedFilter == filters[index];
                return GestureDetector(
                  onTap: () {
                    if (filters[index] == DateFilter.custom) {
                      _pickCustomDate();
                    } else {
                      setState(() => _selectedFilter = filters[index]);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primaryForeground : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<FinancialTransaction>>(
            stream: _getTransactions(),
            builder: (context, snapshot) {
              final transactions = snapshot.data ?? [];
              double totalSales = 0;
              double totalPurchases = 0;
              for (var tx in transactions) {
                if (tx.type == 'sale' || tx.type == 'paid') {
                  totalSales += tx.amount;
                }
                if (tx.type == 'purchase') {
                  totalPurchases += tx.amount;
                }
                if (tx.type == 'refund') {
                  totalPurchases -= tx.amount;
                }
              }
              return StreamBuilder<double>(
                stream: widget._service.getTotalRemainingDebt(),
                builder: (context, debtSnapshot) {
                  final totalDebt = debtSnapshot.data ?? 0;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: isSmallScreen
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  _MetricCard(
                                    label: t.sales,
                                    value: totalSales.toStringAsFixed(0),
                                    tone: _MetricTone.success,
                                    onTap: () => _showEditSalesDialog(context, totalSales),
                                  ),
                                  const SizedBox(width: 10),
                                  _MetricCard(
                                    label: t.expenses,
                                    value: totalPurchases.toStringAsFixed(0),
                                    tone: _MetricTone.warning,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _MetricCard(
                                label: t.debt,
                                value: totalDebt.toStringAsFixed(0),
                                tone: _MetricTone.info,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              _MetricCard(
                                label: t.sales,
                                value: totalSales.toStringAsFixed(0),
                                tone: _MetricTone.success,
                                onTap: () => _showEditSalesDialog(context, totalSales),
                              ),
                              const SizedBox(width: 10),
                              _MetricCard(
                                label: t.expenses,
                                value: totalPurchases.toStringAsFixed(0),
                                tone: _MetricTone.warning,
                              ),
                              const SizedBox(width: 10),
                              _MetricCard(
                                label: t.debt,
                                value: totalDebt.toStringAsFixed(0),
                                tone: _MetricTone.info,
                              ),
                            ],
                          ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.transactions,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryKeys.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final key = _categoryKeys[index];
                      final color = _getCategoryColor(key);
                      final selected = _selectedCategoryKey == key;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryKey = key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(key), size: 13, color: selected ? color : AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(
                                _getCategoryLabel(key),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? color : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: t.searchTransactions,
                hintStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<FinancialTransaction>>(
              stream: _getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                final allTransactions = snapshot.data ?? [];
                final filtered = allTransactions.where((tx) => _filterByCategory(tx)).toList();
                final searched = _searchQuery.isEmpty
                    ? filtered
                    : filtered.where((tx) =>
                        tx.note.toLowerCase().contains(_searchQuery) ||
                        tx.amount.toString().contains(_searchQuery) ||
                        tx.type.toLowerCase().contains(_searchQuery)).toList();
                if (searched.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Text(
                        t.noTransactions,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    itemCount: searched.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final tx = searched[index];
                      final isPositive = tx.type == 'sale' || tx.type == 'paid' || tx.type == 'refund';
                      final isNegative = tx.type == 'purchase';
                      final typeLabel = _getTypeLabel(tx);
                      final typeColor = _getTypeColor(typeLabel);
                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(t.deleteTransaction,
                                  style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
                              content: Text(
                                '${t.areYouSureDelete}?',
                                style: GoogleFonts.ibmPlexSansArabic(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(t.cancel, style: GoogleFonts.ibmPlexSansArabic()),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(t.delete,
                                      style: GoogleFonts.ibmPlexSansArabic(color: AppColors.destructiveForeground)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await widget._service.deleteTransaction(tx.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.transactionDeleted)),
                            );
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.destructive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: AppColors.destructiveForeground),
                        ),
                        child: _TransactionRow(
                          title: tx.note,
                          subtitle: tx.unitPrice != null && tx.quantity != null
                              ? '${tx.unitPrice!.toStringAsFixed(0)} EGP x ${tx.quantity}'
                              : '',
                          typeLabel: typeLabel,
                          typeColor: typeColor,
                          date: DateFormat('dd/MM/yyyy').format(tx.date),
                          amount:
                              '${isPositive ? '+' : '-'}${tx.amount.toStringAsFixed(0)} EGP',
                          positive: isPositive,
                          negative: isNegative,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showEditSalesDialog(BuildContext context, double currentSales) {
    final controller = TextEditingController(
      text: currentSales.toStringAsFixed(0),
    );
    final t = TranslationService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editSales, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.current}: ${currentSales.toStringAsFixed(0)} EGP',
              style: GoogleFonts.ibmPlexSansArabic(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.newAmount,
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                hintText: t.tr('Enter new sales total', 'أدخل إجمالي المبيعات الجديد'),
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
              final newAmount = double.tryParse(controller.text) ?? 0;
              final difference = newAmount - currentSales;
              if (difference == 0) {
                if (ctx.mounted) Navigator.pop(ctx);
                return;
              }

              final service = FinancialService();
              if (difference > 0) {
                await service.addTransaction(FinancialTransaction(
                  id: '',
                  amount: difference,
                  type: 'sale',
                  note: t.manualSalesAdjustment,
                  date: DateTime.now(),
                ));
              } else {
                await service.addTransaction(FinancialTransaction(
                  id: '',
                  amount: difference.abs(),
                  type: 'purchase',
                  note: t.manualSalesAdjustment,
                  date: DateTime.now(),
                ));
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${t.salesUpdatedTo} ${newAmount.toStringAsFixed(0)} EGP")),
                );
              }
            },
            child: Text(t.save, style: GoogleFonts.ibmPlexSansArabic()),
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
  final _MetricTone tone;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
    this.onTap,
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _toneColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$value EGP',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _toneColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String typeLabel;
  final Color typeColor;
  final String date;
  final String amount;
  final bool positive;
  final bool negative;

  const _TransactionRow({
    required this.title,
    this.subtitle = '',
    this.typeLabel = '',
    this.typeColor = AppColors.mutedForeground,
    required this.date,
    required this.amount,
    required this.positive,
    this.negative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: negative
                  ? AppColors.destructive.withValues(alpha: 0.15)
                  : positive
                      ? AppColors.successSoft
                      : AppColors.warningSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              negative
                  ? Icons.shopping_cart_outlined
                  : positive
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
              color: negative
                  ? AppColors.destructive
                  : positive
                      ? AppColors.success
                      : AppColors.warning,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (typeLabel.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              typeLabel,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: negative
                  ? AppColors.destructive
                  : positive
                      ? AppColors.success
                      : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
