import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:qr_barcode_tutorial/theme.dart';
import 'package:qr_barcode_tutorial/models/product.dart';
import 'package:qr_barcode_tutorial/services/firestore_service.dart';
import 'package:qr_barcode_tutorial/services/financial_service.dart';
import 'package:qr_barcode_tutorial/services/translation_service.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wholesalePriceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  QrImageView? _qrImageView;
  String _qrValue = '';

  void _shareQr() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/qr_code.png");
    await file.writeAsBytes(image);

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: "QR Code - HotLine");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wholesalePriceController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationService();
    return Scaffold(
      appBar: AppBar(
        title: Text(t.generateQR),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t.productName,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: t.enterProductName,
              hintStyle: GoogleFonts.ibmPlexSansArabic(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.wholesalePrice,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _wholesalePriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t.wholesalePriceHint,
              hintStyle: GoogleFonts.ibmPlexSansArabic(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.sellingPrice,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t.sellingPriceHint,
              hintStyle: GoogleFonts.ibmPlexSansArabic(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.quantity,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t.enterQuantity,
              hintStyle: GoogleFonts.ibmPlexSansArabic(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _wholesalePriceController.text.isEmpty ||
                    _priceController.text.isEmpty ||
                    _quantityController.text.isEmpty) {
                  return;
                }

                String qrValue =
                    DateTime.now().millisecondsSinceEpoch.toString();

                setState(() {
                  _qrValue = qrValue;
                  _qrImageView = QrImageView(
                    data: qrValue,
                    version: QrVersions.auto,
                    size: 200.0,
                  );
                });

                final service = FirestoreService();
                final wholesalePrice = double.parse(_wholesalePriceController.text);
                final sellingPrice = double.parse(_priceController.text);
                final qty = int.parse(_quantityController.text);
                final product = Product(
                  id: '',
                  name: _nameController.text,
                  barcode: '',
                  qrCode: qrValue,
                  type: 'qr',
                  price: sellingPrice,
                  wholesalePrice: wholesalePrice,
                  quantity: qty,
                  createdAt: DateTime.now(),
                );
                await service.addProduct(product);

                final financialService = FinancialService();
                await financialService.recordPurchase(
                  wholesalePrice * qty,
                  _nameController.text,
                  qty,
                  wholesalePrice,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.productSaved)),
                  );
                }
              },
              child: Text(t.generate, style: GoogleFonts.ibmPlexSansArabic()),
            ),
          ),
          if (_qrImageView != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.codeBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "HotLine",
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _qrImageView!,
                      const SizedBox(height: 8),
                      Text(
                        _qrValue,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _shareQr,
                icon: const Icon(Icons.share, size: 18),
                label: Text(t.sharePrint, style: GoogleFonts.ibmPlexSansArabic()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
