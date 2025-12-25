import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fooddeliveryapp/pages/onboarding.dart'; // Đảm bảo trang Onboarding nằm trong thư mục pages
import 'package:fooddeliveryapp/pages/role_selection.dart'; // Đã cập nhật theo tên file bạn cung cấp
import 'package:fooddeliveryapp/service/constant.dart';

void main() async {
  // Đảm bảo các dịch vụ hệ thống được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Stripe (Key từ file constant.dart)
  Stripe.publishableKey = publishedkey;

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodGo Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Màu chủ đạo đỏ cam đồng bộ với nhận diện thương hiệu FoodGo
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffef2b39)),
        useMaterial3: true,
      ),

      // THAY ĐỔI: Trang đầu tiên hiển thị khi mở app là Onboarding
      home: const Onboarding(),

      // Đăng ký Route cho trang RoleSelectionScreen để dễ dàng điều hướng
      routes: {
        '/role_selection': (context) => const RoleSelectionScreen(),
      },
    );
  }
}
