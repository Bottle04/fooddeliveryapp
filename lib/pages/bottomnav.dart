// lib/pages/bottomnav.dart
// 💡 LƯU Ý: Bạn cần đảm bảo các file 'home.dart', 'order.dart', 'wallet.dart', 'profile.dart' tồn tại
// và được đặt đúng trong thư mục 'pages/'.

import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/home.dart';
import 'package:fooddeliveryapp/pages/order.dart';
import 'package:fooddeliveryapp/pages/profile.dart';
import 'package:fooddeliveryapp/pages/wallet.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Home homePage;
  late Order orderPage;
  late Wallet walletPage;
  late Profile profilePage;

  @override
  void initState() {
    homePage = const Home();
    orderPage = const Order();
    walletPage = const Wallet();
    profilePage = const Profile();
    
    pages = [homePage, orderPage, walletPage, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 15.0),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Icon (Index 0)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTabIndex = 0;
                  });
                },
                child: Icon(
                  Icons.home_outlined,
                  size: 30.0,
                  color: currentTabIndex == 0 ? Colors.red : Colors.white,
                ),
              ),
              
              // Order/Bag Icon (Index 1)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTabIndex = 1;
                  });
                },
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 30.0,
                  color: currentTabIndex == 1 ? Colors.red : Colors.white,
                ),
              ),
              
              // Wallet Icon (Index 2)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTabIndex = 2;
                  });
                },
                child: Icon(
                  Icons.wallet_outlined,
                  size: 30.0,
                  color: currentTabIndex == 2 ? Colors.red : Colors.white,
                ),
              ),
              
              // Profile Icon (Index 3)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTabIndex = 3;
                  });
                },
                child: Icon(
                  Icons.person_outline,
                  size: 30.0,
                  color: currentTabIndex == 3 ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}