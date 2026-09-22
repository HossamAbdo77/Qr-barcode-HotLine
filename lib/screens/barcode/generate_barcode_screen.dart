import 'dart:io' as io;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_barcode_tutorial/theme.dart';
import 'package:qr_barcode_tutorial/models/product.dart';
import 'package:qr_barcode_tutorial/services/firestore_service.dart';
import 'package:qr_barcode_tutorial/services/financial_service.dart';
import 'package:qr_barcode_tutorial/services/translation_service.dart';

class GenerateBarcodeScreen extends StatefulWidget {
  const GenerateBarcodeScreen({super.key});

  @override
  State<GenerateBarcodeScreen> createState() => _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState extends State<GenerateBarcodeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wholesalePriceController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  String? _barcodeSvg;

  _buildBarcode(
    Barcode bc,
    String data, {
    String? filename,
    double? width,
    double? height,
    double? fontHeight,
  }) async {
    final svg = bc.toSvg(
      data,
      width: width ?? 200,
      height: height ?? 80,
      fontHeight: fontHeight,
    );

    filename ??= bc.name.replaceAll(RegExp(r'\s'), '-').toLowerCase();

    var dir = io.Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    var file = io.File("${dir!.path}/$filename.svg");
    file.writeAsStringSync(svg);

    setState(() {
      _barcodeSvg = svg;
    });
  }

  void _shareBarcode() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final dir = await getTemporaryDirectory();
    final file = io.File("${dir.path}/barcode.png");
    await file.writeAsBytes(image);

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: "Barcode - HotLine");
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
        title: Text(t.generateBarcode),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t.productName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: t.enterProductName,
              hintStyle: const TextStyle(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.wholesalePrice,
            style: const TextStyle(
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
              hintStyle: const TextStyle(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.sellingPrice,
            style: const TextStyle(
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
              hintStyle: const TextStyle(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.quantity,
            style: const TextStyle(
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
              hintStyle: const TextStyle(),
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

                String barcodeValue =
                    DateTime.now().millisecondsSinceEpoch.toString();

                await _buildBarcode(
                  Barcode.code128(),
                  barcodeValue,
                  filename: DateTime.now()
                      .toIso8601String()
                      .replaceAll(":", "")
                      .replaceAll(".", "")
                      .replaceAll(" ", "")
                      .replaceAll("T", "")
                      .replaceAll("Z", ""),
                  height: 80,
                  width: 200,
                );

                final service = FirestoreService();
                final wholesalePrice =
                    double.parse(_wholesalePriceController.text);
                final sellingPrice = double.parse(_priceController.text);
                final qty = int.parse(_quantityController.text);
                final product = Product(
                  id: '',
                  name: _nameController.text,
                  barcode: barcodeValue,
                  qrCode: '',
                  type: 'barcode',
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
              child: Text(t.generate),
            ),
          ),
          if (_barcodeSvg != null) ...[
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SvgPicture.string(_barcodeSvg!),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _shareBarcode,
                icon: const Icon(Icons.share, size: 18),
                label: Text(t.sharePrint),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
