// file: forgot_password.dart

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

  // Biến trạng thái để kiểm soát nút gửi (giúp chặn click khi đang xử lý)
  bool _isLoading = false;

  Future resetPassword() async {
    // Kiểm tra email rỗng
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập địa chỉ email."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Bắt đầu tải
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      // Thông báo thành công
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email đặt lại mật khẩu đã được gửi!"),
          backgroundColor: Colors.green,
        ),
      );

      // Chuyển về màn hình Đăng nhập sau khi gửi
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đã xảy ra lỗi. Vui lòng kiểm tra email.";
      if (e.code == 'user-not-found') {
        errorMessage = "Không tìm thấy tài khoản với email này.";
      }

      // Thông báo lỗi
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $errorMessage"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi không xác định: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc tải
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefbf),
      // Fix lỗi tràn màn hình bằng cách sử dụng SingleChildScrollView
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // ---------------- TOP AREA (Header/Logo) ----------------
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

            // ---------------- WHITE CARD (Content) ----------------
            // Đảm bảo chiều cao của Stack là đủ, nếu không, Card sẽ nằm không đúng vị trí
            Container(
              // Chiều cao của màn hình, sử dụng MediaQuery.of(context).size.height an toàn hơn
              height: MediaQuery.of(context).size.height,
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.32,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                width: double.infinity,
                // Không cần đặt height cố định cho Card nếu có SingleChildScrollView
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
                        keyboardType: TextInputType.emailAddress,
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
                        onTap: _isLoading
                            ? null
                            : resetPassword, // Vô hiệu hóa khi đang tải
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? Colors.grey
                                : const Color(0xffef2b39),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 3),
                                  )
                                : Text(
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
                    const SizedBox(height: 40), // Thêm khoảng đệm cuối
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
