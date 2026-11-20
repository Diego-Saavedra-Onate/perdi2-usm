import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'perdi2_usm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        scaffoldBackgroundColor: kBackgroundColor,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
