import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_barcode_tutorial/theme.dart';
import 'package:qr_barcode_tutorial/services/translation_service.dart';
import 'package:qr_barcode_tutorial/screens/barcode/generate_barcode_screen.dart';
import 'package:qr_barcode_tutorial/screens/barcode/scan_barcode_screen.dart';
import 'package:qr_barcode_tutorial/screens/inventory_screen.dart';
import 'package:qr_barcode_tutorial/screens/qr/generate_qr_screen.dart';
import 'package:qr_barcode_tutorial/screens/qr/scan_qr_screen.dart';
import 'package:qr_barcode_tutorial/screens/financial_screen.dart';
import 'package:qr_barcode_tutorial/screens/debt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _translation = TranslationService();

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _translation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _translation.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _translation;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeContent(onNavigate: _switchTab),
          const InventoryScreen(),
          FinancialScreen(),
          DebtScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _switchTab,
          backgroundColor: AppColors.background.withValues(alpha: 0.95),
          elevation: 0,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: Colors.transparent,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, color: AppColors.mutedForeground, size: 22),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary, size: 22),
              label: t.tr('Home', 'الرئيسية'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined, color: AppColors.mutedForeground, size: 22),
              selectedIcon: const Icon(Icons.inventory_2, color: AppColors.primary, size: 22),
              label: t.tr('Inventory', 'المخزون'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.mutedForeground, size: 22),
              selectedIcon: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 22),
              label: t.tr('Finance', 'المالية'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline, color: AppColors.mutedForeground, size: 22),
              selectedIcon: const Icon(Icons.people, color: AppColors.primary, size: 22),
              label: t.tr('Debts', 'الديون'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Function(int) onNavigate;

  const _HomeContent({required this.onNavigate});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _translation = TranslationService();

  @override
  void initState() {
    super.initState();
    _translation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _translation.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _translation;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/LOGO.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'HotLine',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => t.toggle(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    t.isArabic ? 'EN' : 'عربي',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.manageStore,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            t.quickActions,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _ActionCard(
                icon: Icons.qr_code_scanner,
                title: t.scanCode,
                subtitle: t.sellProduct,
                primary: true,
                onTap: () => _showScanOptions(context),
              ),
              _ActionCard(
                icon: Icons.add_circle_outline,
                title: t.addProduct,
                subtitle: t.qrOrBarcode,
                onTap: () => _showCreateOptions(context),
              ),
              _ActionCard(
                icon: Icons.inventory_2_outlined,
                title: t.inventory,
                subtitle: t.viewStock,
                onTap: () => widget.onNavigate(1),
              ),
              _ActionCard(
                icon: Icons.people_outline,
                title: t.debts,
                subtitle: t.manageAccounts,
                onTap: () => widget.onNavigate(3),
              ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  void _showScanOptions(BuildContext context) {
    final t = TranslationService();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.scanCode,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
              title: Text(t.tr('Scan QR Code', 'مسح QR'), style: GoogleFonts.ibmPlexSansArabic()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQrScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.barcode_reader, color: AppColors.primary),
              title: Text(t.tr('Scan Barcode', 'مسح باركود'), style: GoogleFonts.ibmPlexSansArabic()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanBarcodeScreen()));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    final t = TranslationService();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.tr('Create Code', 'إنشاء كود'),
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.primary),
              title: Text(t.tr('Generate QR Code', 'إنشاء QR'), style: GoogleFonts.ibmPlexSansArabic()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GenerateQrScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.barcode_reader, color: AppColors.primary),
              title: Text(t.tr('Generate Barcode', 'إنشاء باركود'), style: GoogleFonts.ibmPlexSansArabic()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GenerateBarcodeScreen()));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool primary;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.primary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primary ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primary ? AppColors.primaryForeground : AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primary ? AppColors.primaryForeground : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: primary
                      ? AppColors.primaryForeground.withValues(alpha: 0.7)
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
