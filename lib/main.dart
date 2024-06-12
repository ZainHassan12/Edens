import 'package:edens_tech/screens/splashScreen.dart';
import 'package:edens_tech/string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';  // Import GetX

import 'firebase_options.dart';

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
    return GetMaterialApp(
      title: title,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: regular,
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
