# Scan & Sell Suite

# HotLine - مشروع Flutter لإدارة المنتجات عبر QR و Barcode

---

## ملخص المشروع

- **اسم المشروع**: HotLine
- **نوعه**: تطبيق موبايل لإدارة المنتجات و المبيعات والديون
- **التقنية**: Flutter + Firebase (Firestore)
- **العملة**: جنيه مصري (EGP)
- **SDK**: Dart ^3.5.0
- **النظام**: Android & iOS (iOS غير مُعد بالكامل)
- **الثيم**: داكن (ThemeData.dark())
- **إدارة الحالة**: setState + StreamBuilder (بدون Bloc/Provider/Riverpod)
- **التنقل**: Navigator.push مباشرة (بدون Routes رسمية)

---

## هيكل المجلدات (Folder Structure)

```
lib/
├── main.dart                              # نقطة الدخول
├── firebase_options.dart                  # إعدادات Firebase
├── models/
│   ├── product.dart                       # نموذج المنتج
│   ├── financial_transaction.dart         # نموذج المعاملة المالية
│   ├── debt.dart                          # نموذج الدين
│   └── debt_payment.dart                  # نموذج دفع الدين
├── screens/
│   ├── home_screen.dart                   # الشاشة الرئيسية (7 أزرار)
│   ├── inventory_screen.dart              # شاشة المخزون
│   ├── product_detail_screen.dart         # تفاصيل المنتج والبيع
│   ├── financial_screen.dart              # الشاشة المالية
│   ├── debt_screen.dart                   # شاشة الديون
│   ├── debt_detail_screen.dart            # تفاصيل الدين
│   ├── qr/
│   │   ├── generate_qr_screen.dart        # إنشاء QR Code
│   │   └── scan_qr_screen.dart            # مسح QR Code
│   └── barcode/
│       ├── generate_barcode_screen.dart    # إنشاء Barcode
│       └── scan_barcode_screen.dart        # مسح Barcode
└── services/
    ├── firestore_service.dart             # خدمة Firestore للمنتجات
    └── financial_service.dart             # خدمة Firestore للمالية
```

---

## الاعتماديّات (Dependencies)

### pubspec.yaml كامل:

```yaml
name: qr_barcode_tutorial
description: "A new Flutter project."
version: 1.0.0+1

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.5
  flutter_svg: ^2.0.17
  qr_flutter: ^4.1.0
  barcode: ^2.2.9
  qr_code_scanner_plus: ^2.0.10+1
  simple_barcode_scanner: ^0.3.0
  firebase_core: ^3.12.1
  cloud_firestore: ^5.6.5
  cupertino_icons: ^1.0.8
  printing: ^5.14.3
  screenshot: ^3.0.0
  share_plus: ^12.0.2
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

### شرح كل اعتمادية:

| الباقة | الوظيفة |
|--------|---------|
| `firebase_core` | تهيئة Firebase |
| `cloud_firestore` | قاعدة البيانات السحابية Firestore |
| `qr_flutter` | إنشاء أكواد QR بصيغة widget |
| `qr_code_scanner_plus` | مسح QR بالكاميرا (Android/iOS) |
| `simple_barcode_scanner` | مسح Barcode بالكاميرا |
| `barcode` | إنشاء أكواد Barcode بصيغة SVG |
| `flutter_svg` | عرض ملفات SVG |
| `screenshot` | التقاط لقطات شاشة لأي widget |
| `share_plus` | مشاركة الصور والملفات |
| `path_provider` | الوصول إلى مسارات التخزين |
| `printing` | الطباعة |
| `intl` | تنسيق التواريخ |
| `flutter_svg` | عرض SVG |

---

## Assets

| الملف | المسار |
|-------|--------|
| LOGO.png | `assets/LOGO.png` |

---

## Firebase Configuration

- **اسم المشروع**: `barcode-qrcode-hotline`
- **Android**: مُعد بالكامل
- **iOS**: غير مُعد (يحتوي قيم نموذجية)
- **Firestore Collections**: `products`, `financial_transactions`, `debts`, `debt_payments`
- **القواعد**: مفتوحة بالكامل (قراءة/كتابة/حذف للجميع بدون مصادقة)

---

## الكود الكامل لكل ملف

### 1. main.dart (نقطة الدخول)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_barcode_tutorial/firebase_options.dart';
import 'package:qr_barcode_tutorial/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter QR/Barcode Generator/Scanner',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
```

---

### 2. النماذج (Models)

#### product.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String barcode;
  final String qrCode;
  final String type;        // 'barcode' أو 'qr'
  final double price;       // بالجنيه المصري
  final int quantity;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.qrCode,
    required this.type,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'qrCode': qrCode,
      'type': type,
      'price': price,
      'quantity': quantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      qrCode: map['qrCode'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

#### financial_transaction.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialTransaction {
  final String id;
  final double amount;
  final String type;    // 'sale', 'paid', 'payment'
  final String note;
  final DateTime date;

  FinancialTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }

  factory FinancialTransaction.fromMap(String id, Map<String, dynamic> map) {
    return FinancialTransaction(
      id: id,
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

#### debt.dart

```dart
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
```

#### debt_payment.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DebtPayment {
  final String id;
  final String debtId;
  final double amount;
  final String note;
  final DateTime date;

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'debtId': debtId,
      'amount': amount,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }

  factory DebtPayment.fromMap(String id, Map<String, dynamic> map) {
    return DebtPayment(
      id: id,
      debtId: map['debtId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

---

### 3. الخدمات (Services)

#### firestore_service.dart (خدمة المنتجات)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  // إضافة منتج
  Future<String> addProduct(Product product) async {
    final docRef = _productsRef.doc();
    await docRef.set(product.toMap());
    return docRef.id;
  }

  // جلب منتج بالمعرّف
  Future<Product?> getProductById(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // جلب منتج بقيمة Barcode أو QR (يبحث في الحقلين)
  Future<Product?> getProductByBarcode(String barcodeValue) async {
    var query = await _productsRef
        .where('barcode', isEqualTo: barcodeValue)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }

    query = await _productsRef
        .where('qrCode', isEqualTo: barcodeValue)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  // Stream لجلب جميع المنتجات (مرتبة تنازلياً)
  Stream<List<Product>> getAllProducts() {
    return _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // بيع منتج (Transaction آمنة)
  Future<bool> sellProduct(String productId, int quantityToSell) async {
    final docRef = _productsRef.doc(productId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentQty = data['quantity'] ?? 0;

      if (currentQty < quantityToSell) return false;

      transaction.update(docRef, {
        'quantity': currentQty - quantityToSell,
      });
      return true;
    });
  }

  // حذف منتج
  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  // إضافة مخزون (Transaction آمنة)
  Future<bool> addStock(String productId, int quantityToAdd) async {
    final docRef = _productsRef.doc(productId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentQty = data['quantity'] ?? 0;

      transaction.update(docRef, {
        'quantity': currentQty + quantityToAdd,
      });
      return true;
    });
  }
}
```

#### financial_service.dart (خدمة المالية)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_transaction.dart';
import '../models/debt.dart';
import '../models/debt_payment.dart';

class FinancialService {
  final _transactionsRef =
      FirebaseFirestore.instance.collection('financial_transactions');
  final _debtsRef = FirebaseFirestore.instance.collection('debts');
  final _paymentsRef = FirebaseFirestore.instance.collection('debt_payments');

  // إضافة معاملة مالية
  Future<void> addTransaction(FinancialTransaction transaction) async {
    await _transactionsRef.doc().set(transaction.toMap());
  }

  // Stream لجلب جميع المعاملات (مرتبة تنازلياً)
  Stream<List<FinancialTransaction>> getAllTransactions() {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                FinancialTransaction.fromMap(doc.id, doc.data()))
            .toList());
  }

  // حساب إجمالي المبيعات
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

  // حساب إجمالي المدفوعات
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

  // حساب إجمالي الديون المتبقية
  Future<double> getTotalDebt() async {
    final snapshot = await _debtsRef.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['remainingDebt'] ?? 0).toDouble();
    }
    return total;
  }

  // إضافة دين جديد
  Future<String> addDebt(Debt debt) async {
    final docRef = _debtsRef.doc();
    await docRef.set(debt.toMap());
    return docRef.id;
  }

  // Stream لجلب جميع الديون
  Stream<List<Debt>> getAllDebts() {
    return _debtsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Debt.fromMap(doc.id, doc.data()))
            .toList());
  }

  // جلب دين محدد
  Future<Debt?> getDebt(String debtId) async {
    final doc = await _debtsRef.doc(debtId).get();
    if (!doc.exists) return null;
    return Debt.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // تسجيل دفعة دين (Transaction + سجل دفعة + معاملة مالية)
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
      note: 'Debt payment',
      date: DateTime.now(),
    ));
  }

  // Stream لجلب مدفوعات دين محدد
  Stream<List<DebtPayment>> getPaymentsForDebt(String debtId) {
    return _paymentsRef
        .where('debtId', isEqualTo: debtId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DebtPayment.fromMap(doc.id, doc.data()))
            .toList());
  }

  // تسجيل بيع كمبيعة مدفوعة
  Future<void> recordSale(double amount, String productName, int quantity) async {
    await addTransaction(FinancialTransaction(
      id: '',
      amount: amount,
      type: 'sale',
      note: '$productName x$quantity',
      date: DateTime.now(),
    ));
  }

  // تسجيل بيع كدين لشخص
  Future<void> addSaleAsDebt(double amount, String productName, int quantity,
      String personName) async {
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
    ));
  }
}
```

---

### 4. الشاشات (Screens)

#### home_screen.dart (الشاشة الرئيسية)

**الوظيفة**: تعرض 7 أزرار للتنقل بين الشاشات المختلفة

**الأزرار**:
1. Generate QR Code → `GenerateQrScreen`
2. Generate Barcode → `GenerateBarcodeScreen`
3. Scan QR Code → `ScanQrScreen`
4. Scan Barcode → `ScanBarcodeScreen`
5. Inventory ( مع أيقونة `Icons.inventory_2`) → `InventoryScreen`
6. Financial ( مع أيقونة `Icons.account_balance_wallet`) → `FinancialScreen`
7. Debts ( مع أيقونة `Icons.people`) → `DebtScreen`

**التصميم**:
- `AppBar` بعنوان "HotLine" بخط عريض حجم 28 و `letterSpacing: 3`
- نص "Select what you want to do.." حجم 18 bold
- `Divider` فاصل بين كل مجموعة أزرار
- الأزرار `ElevatorButton.icon` في `Row` بمحاذاة وسط

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "HotLine",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: (MediaQuery.sizeOf(context).width) * 0.9,
                child: const Text(
                  "Select what you want to do..",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 10),
          // ... 7 أزرار التنقل
        ],
      ),
    );
  }
}
```

---

#### generate_qr_screen.dart (إنشاء QR Code)

**الوظيفة**: إدخال بيانات منتج جديد وإنشاء QR Code له

**المدخلات**:
- Name (TextFormField)
- Price (TextFormField - رقمي)
- Quantity (TextFormField - رقمي)

**آلية العمل**:
1. عند الضغط على "Generate" → يتحقق من صحة المدخلات
2. يولد قيمة QR فريدة: `DateTime.now().millisecondsSinceEpoch.toString()`
3. يعرض الـ QR Code باستخدام `QrImageView` (حجم 200)
4. يحفظ المنتج في Firestore عبر `FirestoreService.addProduct()`
5. يعرض `SnackBar` "Product saved to inventory"
6. يعرض زر "Share / Print" بعد التوليد

**المشاركة**: يلتقط لقطة شاشة للـ widget ويحفظها كـ PNG ثم يشاركها عبر `Share.shareXFiles`

**التصميم**:
- `ListView` بـ padding 10
- حقول الإدخال بـ `OutlineInputBorder` و `borderRadius: 10`
- الـ QR يظهر داخل `Container` أبيض بعنوان "HotLine"
- `Screenshot` widget لالتقاط الصورة

```dart
class GenerateQrScreen extends StatefulWidget {
  @override
  _GenerateQrScreenState createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  ScreenshotController _screenshotController = ScreenshotController();

  QrImageView? _qrImageView;
  String _qrData = "";

  void _shareQr() async {
    final image = await _screenshotController.capture();
    if (image == null) return;
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/qr_code.png");
    await file.writeAsBytes(image);
    await Share.shareXFiles([XFile(file.path)], text: "QR Code - HotLine");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Generate QR Code"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        children: [
          // Name, Price, Quantity TextFormFields
          // Generate Button
          // QR Code display (if generated)
          // Share / Print button (if QR exists)
        ],
      ),
    );
  }
}
```

---

#### generate_barcode_screen.dart (إنشاء Barcode)

**الوظيفة**: إدخال بيانات منتج جديد وإنشاء Barcode (Code128)

**المدخلات**: Name, Price, Quantity (نفس generate_qr_screen)

**آلية العمل**:
1. يولد قيمة Barcode فريدة: `DateTime.now().millisecondsSinceEpoch.toString()`
2. ينشئ Barcode بصيغة SVG عبر `Barcode.code128().toSvg()` (عرض 200، ارتفاع 80)
3. يعرض الـ Barcode عبر `SvgPicture.string()`
4. يحفظ المنتج في Firestore
5. يوفر مشاركة/طباعة

```dart
class GenerateBarcodeScreen extends StatefulWidget {
  @override
  _GenerateBarcodeScreenState createState() => _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState extends State<GenerateBarcodeScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  ScreenshotController _screenshotController = ScreenshotController();

  String? _barcodeSvg;
  String _barcodeData = "";

  _buildBarcode(Barcode bc, String data, {String? filename, double? width, double? height, double? fontHeight}) async {
    final svg = bc.toSvg(data, width: width ?? 200, height: height ?? 80, fontHeight: fontHeight);
    // حفظ SVG في ملف
    var dir = io.Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
    var file = io.File("${dir!.path}/$filename.svg");
    file.writeAsStringSync(svg);
    setState(() {
      _barcodeSvg = svg;
      _barcodeData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Generate Barcode")),
      body: ListView(
        // Name, Price, Quantity TextFormFields
        // Generate Button
        // Barcode display (if generated)
        // Share / Print button (if Barcode exists)
      ),
    );
  }
}
```

---

#### scan_qr_screen.dart (مسح QR Code)

**الوظيفة**: فتح الكاميرا لمسح QR Code

**آلية العمل**:
1. يستخدم `QRView` من `qr_code_scanner_plus`
2. عند المسح → يتوقف عن المسح (`pauseCamera`)
3. ينتقل إلى `ProductDetailScreen(barcodeValue: scanData.code!)`
4. عند العودة → يعيد تشغيل الكاميرا (`resumeCamera`)

```dart
class ScanQrScreen extends StatefulWidget {
  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _scanned = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_scanned && scanData.code != null && scanData.code!.isNotEmpty) {
        _scanned = true;
        controller.pauseCamera();
        Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => ProductDetailScreen(barcodeValue: scanData.code!),
            ))
            .then((_) {
          _scanned = false;
          controller.resumeCamera();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Scan QR Code")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(flex: 5, child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated)),
          const SizedBox(height: 40),
          Expanded(flex: 1, child: Center(child: Text(result != null ? 'Data: ${result!.code}' : 'QR Content Here'))),
        ],
      ),
    );
  }
}
```

---

#### scan_barcode_screen.dart (مسح Barcode)

**الوظيفة**: فتح فاصل الكاميرا لمسح Barcode

**آلية العمل**:
1. يستخدم `SimpleBarcodeScanner.scanBarcode()`
2. عند المسح → ينتقل إلى `ProductDetailScreen(barcodeValue: res)`

```dart
class ScanBarcodeScreen extends StatefulWidget {
  @override
  _ScanBarcodeScreenState createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  String _result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Scan Barcode")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              String? res = await SimpleBarcodeScanner.scanBarcode(
                context,
                barcodeAppBar: const BarcodeAppBar(
                  appBarTitle: 'Scan',
                  centerTitle: false,
                  enableBackButton: true,
                  backButtonIcon: Icon(Icons.arrow_back_ios),
                ),
                isShowFlashIcon: true,
                delayMillis: 2000,
                cameraFace: CameraFace.front,
              );
              if (res != null && res.isNotEmpty) {
                setState(() { _result = res; });
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProductDetailScreen(barcodeValue: res)),
                );
              }
            },
            child: const Text('Open Scanner'),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          if (_result != "")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 40) * 0.8,
                  child: Text("Data: $_result", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
```

---

#### product_detail_screen.dart (تفاصيل المنتج والبيع)

**المُعامل**: `barcodeValue` (القيمة الممسوحة من QR أو Barcode)

**الوظيفة**: عرض تفاصيل المنتج والبيع

**الميزات**:
1. البحث عن المنتج في Firestore بالقيمة الممسوحة
2. عرض: الاسم، السعر، الكمية المتاحة، النوع، الكود
3. التحكم في كمية البيع (+ / -)
4. زر البيع مع 3 خيارات:
   - **Paid**: بيع مدفوع → `recordSale()`
   - **Debt**: بيع كدين → يطلب اسم الشخص → `addSaleAsDebt()`
   - **Cancel**: إلغاء
5. زر حذف المنتج مع تأكيد

```dart
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

  Future<void> _loadProduct() async {
    final product = await _service.getProductByBarcode(widget.barcodeValue);
    setState(() { _product = product; _loading = false; _notFound = product == null; });
  }

  Future<void> _sell() async {
    // Dialog with 3 choices: Paid, Debt, Cancel
    // If Paid: _financialService.recordSale()
    // If Debt: Dialog for name -> _financialService.addSaleAsDebt()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Product Detail")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notFound
              ? const Center(child: Text("Product not found"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name (24, bold)
                      // Price: XX EGP (18)
                      // Available: XX (18, red if 0)
                      // Type: Barcode / QR Code (14, grey)
                      // Code value (14, grey)
                      // Quantity selector (+/-) if quantity > 0
                      // Sell button (full width)
                      // "Out of stock" text if quantity == 0
                      // Delete Product button (red, outlined)
                    ],
                  ),
                ),
    );
  }
}
```

---

#### inventory_screen.dart (شاشة المخزون)

**الوظيفة**: عرض جميع المنتجات في قائمة

**الميزات**:
1. `StreamBuilder` لعرض المنتجات مباشرة من Firestore
2. لكل منتج:
   - أيقونة حسب النوع: `Icons.barcode_reader` (أزرق) أو `Icons.qr_code` (أخضر)
   - الاسم (bold)
   - "Stock: XX | Price: XX EGP"
   - زر حذف (أحمر)
   - سهم `chevron_right`
3. النقر على منتج → `dialog` لإضافة مخزون
4. حذف مع تأكيد

```dart
class InventoryScreen extends StatelessWidget {
  final FirestoreService _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Inventory")),
      body: StreamBuilder<List<Product>>(
        stream: _service.getAllProducts(),
        builder: (context, snapshot) {
          // CircularProgressIndicator if waiting
          // "No products yet" if empty
          // ListView.separated with ListTile for each product
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) { ... }
  void _showAddStockDialog(BuildContext context, Product product) { ... }
}
```

---

#### financial_screen.dart (الشاشة المالية)

**الوظيفة**: عرض ملخص مالي وسجل المعاملات

**الميزات**:
1. **3 بطاقات ملخص** (`_SummaryCards`):
   - Total Sales (أخضر)
   - Paid (أزرق)
   - Debt (برتقالي)
2. **قائمة المعاملات** مع:
   - `CircleAvatar` (أخضر للإيجابي/برتقالي للسلبي)
   - المبلغ مع علامة + أو -
   - الملاحظة (note)
   - التاريخ (dd/MM/yyyy)

```dart
class FinancialScreen extends StatelessWidget {
  final FinancialService _service = FinancialService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Financial")),
      body: Column(
        children: [
          StreamBuilder (transactions for summary cards),
          Divider,
          Text("Transactions"),
          Expanded(
            StreamBuilder (transactions list),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget { ... } // 3 cards in Row
class _Card extends StatelessWidget { ... }         // Single card with color
```

---

#### debt_screen.dart (شاشة الديون)

**الوظيفة**: عرض وإدارة الديون

**الميزات**:
1. `FloatingActionButton` لإضافة دين جديد
2. قائمة بالأشخاص المدينين:
   - `CircleAvatar` (برتقالي إذا متبقي / أخضر إذا تم السداد)
   - اسم الشخص (bold)
   - "Remaining: XX EGP"
   - "Paid: XX" (grey)
3. Dialog الإضافة: Person name, Amount, Note (optional)

```dart
class DebtScreen extends StatelessWidget {
  final FinancialService _service = FinancialService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Debts")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Debt>>(
        stream: _service.getAllDebts(),
        builder: (context, snapshot) {
          // CircularProgressIndicator if waiting
          // "No debts yet" if empty
          // ListView.separated
        },
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    // AlertDialog with name, amount, note fields
    // Creates Debt object and saves via _service.addDebt()
  }
}
```

---

#### debt_detail_screen.dart (تفاصيل الدين)

**المُعامل**: `debt` (نموذج Debt)

**الوظيفة**: عرض تفاصيل دين شخص محدد وإدارة الدفعات

**الميزات**:
1. اسم الشخص في الأعلى (22, bold)
2. **3 بطاقات معلومات** (`_InfoCard`):
   - Total (أزرق)
   - Paid (أخضر)
   - Remaining (برتقالي/أخضر)
3. زر "Pay Debt" يظهر فقط إذا كان `remainingDebt > 0`
4. Dialog الدفع مع التحقق من صحة المبلغ (لا يزيد عن المتبقي)
5. **قائمة Payment History**: المبلغ (أخضر)، الملاحظة، التاريخ

```dart
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.debt.personName)),
      body: Column(
        children: [
          // Person name + 3 InfoCards + Pay Debt button
          Divider
          Text("Payment History")
          Expanded(
            StreamBuilder<List<DebtPayment>>(
              stream: _service.getPaymentsForDebt(widget.debt.id),
              // ListView of payments
            ),
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(BuildContext context) {
    // AlertDialog showing current debt + amount input
    // Validates amount <= remaining
    // Calls _service.payDebt()
  }
}

class _InfoCard extends StatelessWidget { ... }
```

---

## هيكل قاعدة البيانات (Firebase Firestore)

```
products/
  └── {productId}/
      ├── name: String
      ├── barcode: String
      ├── qrCode: String
      ├── type: String ("barcode" | "qr")
      ├── price: Double
      ├── quantity: Integer
      └── createdAt: Timestamp

financial_transactions/
  └── {transactionId}/
      ├── amount: Double
      ├── type: String ("sale" | "paid" | "payment")
      ├── note: String
      └── date: Timestamp

debts/
  └── {debtId}/
      ├── personName: String
      ├── totalDebt: Double
      ├── totalPaid: Double
      ├── remainingDebt: Double
      ├── createdAt: Timestamp
      └── updatedAt: Timestamp

debt_payments/
  └── {paymentId}/
      ├── debtId: String (مرجع لـ debts)
      ├── amount: Double
      ├── note: String
      └── date: Timestamp
```

---

## العلاقات بين الشاشات (Navigation Flow)

```
                         MyApp (MaterialApp)
                             │
                         HomeScreen
                        /    |    \      \       \         \
                       /     |     \      \       \         \
            GenerateQR  GenerateBarcode  ScanQR  ScanBarcode  Inventory  Financial  Debts
                │            │              │          │
                │            │              │          │
                └────┬───────┘              │          │
                     │ (at save)            │          │
                     │                  ProductDetail  │
                     │                  ProductDetail   │
                     │                      │          │
                     │                    DebtScreen    │
                     │                  DebtDetailScreen
```

---

## مسار العمل الأساسي

### 1. إنشاء منتج:
```
HomeScreen → GenerateQrScreen / GenerateBarcodeScreen → (حفظ في Firestore) → العودة
```

### 2. بيع منتج (مسح):
```
HomeScreen → ScanQrScreen / ScanBarcodeScreen → مسح الكود → ProductDetailScreen
    → البيع (Paid أو Debt) → العودة
```

### 3. إدارة المخزون:
```
HomeScreen → InventoryScreen → (عرض / إضافة مخزون / حذف)
```

### 4. المالية:
```
HomeScreen → FinancialScreen → (عرض المعاملات والملخص)
```

### 5. الديون:
```
HomeScreen → DebtScreen → DebtDetailScreen → (عرض الدفعات / تسديد الدين)
```

---

## الفئات (Classes) الكاملة

| # | اسم الكلاس | النوع | الملف |
|---|-----------|-------|-------|
| 1 | `MyApp` | StatelessWidget | main.dart |
| 2 | `Product` | Data Model | models/product.dart |
| 3 | `FinancialTransaction` | Data Model | models/financial_transaction.dart |
| 4 | `Debt` | Data Model | models/debt.dart |
| 5 | `DebtPayment` | Data Model | models/debt_payment.dart |
| 6 | `FirestoreService` | Service | services/firestore_service.dart |
| 7 | `FinancialService` | Service | services/financial_service.dart |
| 8 | `HomeScreen` | StatelessWidget | screens/home_screen.dart |
| 9 | `GenerateQrScreen` | StatefulWidget | screens/qr/generate_qr_screen.dart |
| 10 | `ScanQrScreen` | StatefulWidget | screens/qr/scan_qr_screen.dart |
| 11 | `GenerateBarcodeScreen` | StatefulWidget | screens/barcode/generate_barcode_screen.dart |
| 12 | `ScanBarcodeScreen` | StatefulWidget | screens/barcode/scan_barcode_screen.dart |
| 13 | `InventoryScreen` | StatelessWidget | screens/inventory_screen.dart |
| 14 | `ProductDetailScreen` | StatefulWidget | screens/product_detail_screen.dart |
| 15 | `FinancialScreen` | StatelessWidget | screens/financial_screen.dart |
| 16 | `_SummaryCards` | StatelessWidget (private) | screens/financial_screen.dart |
| 17 | `_Card` | StatelessWidget (private) | screens/financial_screen.dart |
| 18 | `DebtScreen` | StatelessWidget | screens/debt_screen.dart |
| 19 | `DebtDetailScreen` | StatefulWidget | screens/debt_detail_screen.dart |
| 20 | `_InfoCard` | StatelessWidget (private) | screens/debt_detail_screen.dart |

**المجموع**: 20 فئة (7 StatefulWidget, 7 StatelessWidget, 4 Data Model, 2 Service)

---

## التصميم التفصيلي لكل شاشة

### الشاشة الرئيسية (HomeScreen):
- **AppBar**: عنوان "HotLine" مركزي، خط粗 حجم 28، مسافة بين الحروف 3
- **الخلفية**: ثيم داكن (ThemeData.dark())
- **المحتوى**: Column يحتوي على:
  - مسافة 40
  - نص "Select what you want to do.." (18 bold)
  - مسافة 40
  - Divider
  - 7 أزرار (كل زر في Row منفصلة)
  - Divider فاصل بين كل مجموعة

### شاشات الإدخال (Generate QR/Barcode):
- **الخلفية**: ListView بـ padding 10
- **الحقول**: TextFormField بـ OutlineInputBorder (borderRadius: 10)
- **الأزرار**: ElevatedButton.icon
- **المعاينة**: Container أبيض داخل Screenshot widget
- **العنوان**: "HotLine" داخل الـ Container الأبيض

### شاشة تفاصيل المنتج:
- **Padding**: 20 من كل الجهات
- **الاسم**: 24 bold
- **التفاصيل**: 18 (السعر والكمية)
- **النوع/الكود**: 14 grey
- **محدد الكمية**: IconButton (remove_circle_outline / add_circle_outline) حجم 32
- **زر البيع**: ElevatedButton عريض padding vertical 15
- **زر الحذف**: OutlinedButton أحمر في الأسفل

### الشاشة المالية:
- **البطاقات**: Container بـ padding 12، borderRadius 10، border بلون خفيف
- **المعاملات**: ListTile مع CircleAvatar ملون

### شاشة الديون:
- **FloatingActionButton**: لإضافة دين جديد
- **القائمة**: ListTile مع CircleAvatar (برتقالي/أخضر)

---

## ملاحظات تقنية مهمة

1. **لا يوجد نظام Routes**: جميع التنقلات عبر `Navigator.push` مع `MaterialPageRoute`
2. **لا يوجد Dependency Injection**: كل شاشة تنشئ الخدمة مباشرة
3. **لا يوجد اختبارات حقيقية**: فقط `widget_test.dart` افتراضي
4. **قواعد Firestore مفتوحة**: لا توجد مصادقة (خطأ أمني)
5. **iOS غير مُعد بالكامل**: يحتوي قيم نموذجية
6. **العملة**: جنيه مصري (EGP) تظهر في كل مكان
7. **التنسيق**: `DateFormat('dd/MM/yyyy')` للتاريخ، `toStringAsFixed(0)` للأرقام
8. **الثيم**: `ThemeData.dark()` بالكامل
عاوز UI جديد للمشروع بالكامل

This project was built with [Lovable](https://lovable.dev).

**Live app**: https://prod-link-track.lovable.app

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/fb7a2e56-33b4-40a4-ae8b-59bdf5916668).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
