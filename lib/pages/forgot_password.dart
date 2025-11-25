import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'login.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email đặt lại mật khẩu đã được gửi!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefbf),
      body: Stack(
        children: [
          // ---------------- TOP AREA ----------------
          Column(
            children: [
              const SizedBox(height: 60),
              Center(
                child: Image.asset(
                  "images/pan.png",
                  height: 150,
                  fit: BoxFit.fill,
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

          // ---------------- WHITE CARD ----------------
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.32,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.68,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Forgot Password",
                    style: AppWidget.HeadlineTextFeildStyle(),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Email",
                  style: AppWidget.SignUpTextFeildStyle(),
                ),
                const SizedBox(height: 8),

                // Input email
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter Email",
                      prefixIcon: Icon(Icons.mail),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Button send email
                Center(
                  child: GestureDetector(
                    onTap: resetPassword,
                    child: Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xffef2b39),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Send Email",
                          style: AppWidget.boldwhiteTextFeildStyle(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Remember password?",
                      style: AppWidget.SimpleTextFeildStyle(),
                    ),
                    const SizedBox(width: 7),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => LogIn()));
                      },
                      child: Text(
                        "LogIn",
                        style: AppWidget.boldTextFeildStyle(),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
