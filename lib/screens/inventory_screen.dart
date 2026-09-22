import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/financial_service.dart';
import '../services/translation_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirestoreService _service = FirestoreService();
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
            child: Text(
              t.inventory,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: t.searchProducts,
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
            child: StreamBuilder<List<Product>>(
              stream: _service.getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                final allProducts = snapshot.data ?? [];
                final products = _searchQuery.isEmpty
                    ? allProducts
                    : allProducts.where((p) =>
                        p.name.toLowerCase().contains(_searchQuery) ||
                        p.price.toString().contains(_searchQuery) ||
                        p.barcode.contains(_searchQuery) ||
                        p.qrCode.contains(_searchQuery)).toList();
                if (allProducts.isEmpty) {
                  return Center(
                    child: Text(
                      t.noProducts,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  );
                }
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      t.noResults,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${products.length} ${t.products}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView.separated(
                          itemCount: products.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return _ProductRow(
                              product: p,
                              onTap: () => _showAddStockDialog(context, p),
                              onDelete: () => _showDeleteDialog(context, p),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    final t = TranslationService();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteProduct,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          "${t.areYouSureDelete} '${product.name}'?",
          style: const TextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel, style: const TextStyle()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive),
            onPressed: () async {
              await _service.deleteProduct(product.id);
              await FinancialService()
                  .deleteTransactionsByProductName(product.name);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("'${product.name}' ${t.productDeleted}")),
                );
              }
            },
            child: Text(t.delete,
                style: const TextStyle(color: AppColors.destructiveForeground)),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, Product product) {
    final controller = TextEditingController();
    final t = TranslationService();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.currentStock}: ${product.quantity}',
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 8),
            Text(
              '${t.cost}: ${product.wholesalePrice.toStringAsFixed(0)} EGP · ${t.sell}: ${product.price.toStringAsFixed(0)} EGP',
              style: const TextStyle(
                  color: AppColors.mutedForeground, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.quantity,
                hintText: t.enterQuantity,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              final qty = int.tryParse(controller.text);
              if (qty == null || qty <= 0) return;
              await _service.addStock(product.id, qty);

              final financialService = FinancialService();
              await financialService.recordPurchase(
                product.wholesalePrice * qty,
                product.name,
                qty,
                product.wholesalePrice,
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${t.addedTo} $qty ${t.products} ${product.name}")),
                );
              }
            },
            child: Text(t.add),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive),
            onPressed: () async {
              final qty = int.tryParse(controller.text);
              if (qty == null || qty <= 0) return;
              if (qty > product.quantity) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.notEnoughStock)),
                  );
                }
                return;
              }
              await _service.sellProduct(product.id, qty);

              final financialService = FinancialService();
              await financialService.recordRefund(
                product.wholesalePrice * qty,
                product.name,
                qty,
                product.wholesalePrice,
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${t.reducedFrom} $qty ${t.products} ${product.name}")),
                );
              }
            },
            child: Text(t.reduce),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = TranslationService();
    final isLowStock = product.quantity < 10;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                product.type == 'barcode'
                    ? Icons.barcode_reader
                    : Icons.qr_code,
                color: AppColors.secondaryForeground,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.barcode.isNotEmpty ? product.barcode : product.qrCode,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    '${product.price.toStringAsFixed(0)} EGP · ${product.price > 0 ? '${t.cost}: ${product.price.toStringAsFixed(0)} · ' : ''}${product.quantity} ${t.pcs}${isLowStock ? ' (${t.low})' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLowStock
                          ? AppColors.warning
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.destructive,
              onPressed: onDelete,
            ),
            const Icon(Icons.chevron_left,
                color: AppColors.mutedForeground, size: 20),
          ],
        ),
      ),
    );
  }
}
