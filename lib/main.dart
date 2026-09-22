import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_barcode_tutorial/firebase_options.dart';
import 'package:qr_barcode_tutorial/theme.dart';
import 'package:qr_barcode_tutorial/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log('Flutter Error: ${details.exceptionAsString()}',
        stackTrace: details.stack, level: 1000);
  };

  runZonedGuarded(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
    runApp(const MyApp());
  }, (error, stack) {
    log('Zone Error: $error', stackTrace: stack, level: 1000);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HotLine',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
