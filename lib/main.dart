import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fooddeliveryapp/pages/bottomnav.dart';
import 'package:fooddeliveryapp/pages/login.dart';
import 'package:fooddeliveryapp/service/constant.dart';
import 'package:fooddeliveryapp/Admin/admin_login.dart';
import 'package:fooddeliveryapp/pages/role_selection.dart'; // chứa Stripe publishable key

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Stripe
  Stripe.publishableKey = publishedkey;

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Hàm check trạng thái đăng nhập
  Future<bool> checkLoginStatus() async {
    // Lấy user hiện tại từ FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(), // ⬅️ Màn hình chọn vai trò
    );
  }
}
