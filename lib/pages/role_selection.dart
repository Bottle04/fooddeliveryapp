import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/login.dart';
import 'package:fooddeliveryapp/Admin/admin_login.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefbf),
      body: Stack(
        children: [
          // ---------- TOP IMAGE + LOGO ----------
          Column(
            children: [
              const SizedBox(height: 70),
              Center(
                child: Image.asset(
                  "images/pan.png",
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                "images/logo.png",
                width: 150,
                height: 50,
                fit: BoxFit.cover,
              ),
            ],
          ),

          // ---------- WHITE CARD ----------
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.36,
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "Who are you ?",
                  style: AppWidget.HeadlineTextFeildStyle(),
                ),
                const SizedBox(height: 30),

                // ========== BUTTON ADMIN ==========
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLogIn()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xffef2b39),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        "👨‍🍳   Admin",
                        style: AppWidget.boldwhiteTextFeildStyle(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ========== BUTTON USER ==========
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogIn()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xffef2b39),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        "👤   User",
                        style: AppWidget.boldwhiteTextFeildStyle(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
