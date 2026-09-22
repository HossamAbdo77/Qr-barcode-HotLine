import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/debt.dart';
import '../services/financial_service.dart';
import '../services/translation_service.dart';
import 'debt_detail_screen.dart';

class DebtScreen extends StatefulWidget {
  final FinancialService _service = FinancialService();

  DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _translation = TranslationService();

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

  @override
  Widget build(BuildContext context) {
    final t = TranslationService();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.debts,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddDebtDialog(context),
                  icon: const Icon(Icons.add, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: t.searchDebtor,
                hintStyle: GoogleFonts.ibmPlexSansArabic(),
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
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Debt>>(
              stream: widget._service.getAllDebts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final debts = snapshot.data ?? [];
                if (debts.isEmpty) {
                  return Center(
                    child: Text(
                      t.noDebts,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  );
                }
                final filtered = _searchQuery.isEmpty
                    ? debts
                    : debts.where((d) => d.personName.toLowerCase().contains(_searchQuery)).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      t.noResults,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final d = filtered[index];
                      final remaining = d.remainingDebt;
                      final isSettled = remaining <= 0;
                      return Dismissible(
                        key: Key(d.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(t.deleteDebtor,
                                  style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
                              content: Text(
                                "${t.areYouSureDelete} '${d.personName}'?",
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
                          await widget._service.deleteDebt(d.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${d.personName} ${t.debtsDeleted}")),
                            );
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.destructive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: AppColors.destructiveForeground),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DebtDetailScreen(debt: d),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSettled ? AppColors.successSoft : AppColors.warningSoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      d.personName.isNotEmpty ? d.personName[0].toUpperCase() : '?',
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontWeight: FontWeight.w700,
                                        color: isSettled ? AppColors.success : AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.personName,
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${t.paid}: ${d.totalPaid.toStringAsFixed(0)} EGP',
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 12,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      isSettled ? t.settled : '${remaining.toStringAsFixed(0)} EGP',
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontWeight: FontWeight.w700,
                                        color: isSettled ? AppColors.success : AppColors.warning,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.remaining,
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontSize: 11,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  void _showAddDebtDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final t = TranslationService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.addDebt, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t.personName,
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                hintText: t.tr('Enter name', 'أدخل الاسم'),
                hintStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.amount,
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
                hintText: t.enterNote,
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
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;
              if (name.isEmpty || amount <= 0) return;

              final now = DateTime.now();
              await widget._service.addDebt(Debt(
                id: '',
                personName: name,
                totalDebt: amount,
                totalPaid: 0,
                remainingDebt: amount,
                createdAt: now,
                updatedAt: now,
              ));

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${t.addedTo} $name")),
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
