import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/financial_service.dart';
import '../services/translation_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String barcodeValue;

  const ProductDetailScreen({super.key, required this.barcodeValue});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _service = FirestoreService();
  final FinancialService _financialService = FinancialService();
  Product? _product;
  bool _loading = true;
  bool _notFound = false;
  int _sellQuantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _service.getProductByBarcode(widget.barcodeValue);
    if (!mounted) return;
    setState(() {
      _product = product;
      _loading = false;
      _notFound = product == null;
    });
  }

  Future<void> _sell() async {
    if (_product == null) return;
    final total = _product!.price * _sellQuantity;
    final t = TranslationService();

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.sell, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${_product!.name} x$_sellQuantity",
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            const SizedBox(height: 8),
            Text(
              "${t.total}: ${total.toStringAsFixed(0)} EGP",
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(t.cancel, style: GoogleFonts.ibmPlexSansArabic()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'paid'),
            child: Text(t.paid, style: GoogleFonts.ibmPlexSansArabic()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'debt'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(t.debt, style: GoogleFonts.ibmPlexSansArabic(color: AppColors.primaryForeground)),
          ),
        ],
      ),
    );

    if (choice == null || choice == 'cancel') return;

    final success = await _service.sellProduct(_product!.id, _sellQuantity);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.notEnoughStock)),
      );
      return;
    }

    if (choice == 'paid') {
      await _financialService.recordSale(
          total, _product!.name, _sellQuantity, _product!.price);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${t.soldItems} $_sellQuantity ${t.pcs} - ${t.paid} ${total.toStringAsFixed(0)} EGP')),
        );
      }
    } else if (choice == 'debt') {
      final name = await _showDebtNamePicker(context);
      if (name != null && name.isNotEmpty) {
        await _financialService.addSaleAsDebt(
            total, _product!.name, _sellQuantity, name, _product!.price);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${t.soldItems} - ${t.debtFor} $name: ${total.toStringAsFixed(0)} EGP')),
          );
        }
      }
    }

    await _loadProduct();
    if (mounted) setState(() => _sellQuantity = 1);
  }

  Future<String?> _showDebtNamePicker(BuildContext context) async {
    final debts = await _financialService.getAllDebts().first;
    final existingNames = debts.map((d) => d.personName).toSet().toList();
    final nameController = TextEditingController();
    final t = TranslationService();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.selectOrEnterName,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (existingNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: existingNames.map((name) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx, name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.warningSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              t.orEnterNewName,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 12,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: t.personName,
                hintStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.pop(ctx, name);
                  }
                },
                child: Text(t.confirm, style: GoogleFonts.ibmPlexSansArabic()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final t = TranslationService();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteProduct, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
        content: Text(
          "${t.areYouSureDelete} '${_product!.name}'?",
          style: GoogleFonts.ibmPlexSansArabic(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel, style: GoogleFonts.ibmPlexSansArabic()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            onPressed: () async {
              await _service.deleteProduct(_product!.id);
              await FinancialService().deleteTransactionsByProductName(_product!.name);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.productDeleted)),
                );
                Navigator.pop(context);
              }
            },
            child: Text(t.delete, style: GoogleFonts.ibmPlexSansArabic(color: AppColors.destructiveForeground)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationService();
    return Scaffold(
      appBar: AppBar(
        title: Text(t.productDetail),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notFound
              ? Center(
                  child: Text(
                    t.productNotFound,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.codeBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _product!.type == 'barcode'
                                  ? Icons.barcode_reader
                                  : Icons.qr_code,
                              size: 80,
                              color: AppColors.codeForeground,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _product!.type == 'barcode'
                                  ? _product!.barcode
                                  : _product!.qrCode,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11,
                                color: AppColors.codeForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _product!.type == 'barcode' ? t.barcode : t.qrCode,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: AppColors.secondaryForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _product!.name,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_product!.price.toStringAsFixed(0)} EGP · ${t.available} ${_product!.quantity} ${t.pcs}',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_product!.quantity > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.sellQuantity,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                _QuantityButton(
                                  icon: Icons.remove,
                                  onTap: _sellQuantity > 1
                                      ? () => setState(() => _sellQuantity--)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '$_sellQuantity',
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _QuantityButton(
                                  icon: Icons.add,
                                  onTap: _sellQuantity < _product!.quantity
                                      ? () => setState(() => _sellQuantity++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _sell,
                          child: Text(
                            '${t.sellNow} · ${(_product!.price * _sellQuantity).toStringAsFixed(0)} EGP',
                            style: GoogleFonts.ibmPlexSansArabic(),
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          t.outOfStock,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 18),
                      label: Text(
                        t.deleteProduct,
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: AppColors.destructive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: onTap != null ? AppColors.primaryForeground : AppColors.mutedForeground,
          size: 18,
        ),
      ),
    );
  }
}
