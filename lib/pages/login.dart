import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/signup.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:fooddeliveryapp/pages/forgot_password.dart';
import 'package:fooddeliveryapp/pages/bottomnav.dart';
import 'package:fooddeliveryapp/service/database.dart'; // Import DatabaseMethods
import 'package:fooddeliveryapp/service/shared_pref.dart'; // Import SharedpreferenceHelper
import 'package:cloud_firestore/cloud_firestore.dart'; // Import cho Firestore

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController mailcontroller = new TextEditingController();

  userLogin() async {
    try {
      // 1. Thực hiện đăng nhập Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // 2. LẤY DỮ LIỆU TÊN TỪ FIRESTORE
        DocumentSnapshot userSnapshot =
            await DatabaseMethods().getUserDetails(user.uid);

        String newName = "Guest User"; // Giá trị mặc định
        String newEmail = user.email ?? email;

        // KIỂM TRA: Nếu Document tồn tại và có field "Name"
        if (userSnapshot.exists) {
          Map<String, dynamic>? data =
              userSnapshot.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey("Name")) {
            newName = data["Name"]; // Lấy tên thật
          }
        }

        // 3. LƯU DỮ LIỆU MỚI vào Shared Preference
        await SharedpreferenceHelper().saveUserEmail(newEmail);
        await SharedpreferenceHelper().saveUserName(newName);
        await SharedpreferenceHelper().saveUserId(user.uid);
      }

      // 4. Chuyển hướng
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "No user Found for that Email",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Wrong Password Provided by User",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Login failed: ${e.message}",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bọc toàn bộ nội dung body bằng SingleChildScrollView
      body: SingleChildScrollView(
        child: Container(
          // Đặt chiều cao bằng chiều cao màn hình để giữ bố cục Stack
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Phần nền trên (Màu vàng và hình ảnh)
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                padding: EdgeInsets.only(top: 30.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xffffefbf),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40))),
                child: Column(
                  children: [
                    Image.asset(
                      "images/pan.png",
                      height: 150,
                      fit: BoxFit.fill,
                      width: 240,
                    ),
                    Image.asset(
                      "images/logo.png",
                      width: 150,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
              ),

              // Thẻ đăng nhập (Login Card)
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3.2,
                    left: 20.0,
                    right: 20.0),
                child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        Center(
                          child: Text(
                            "LogIn",
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: mailcontroller,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Email",
                                prefixIcon: Icon(Icons.mail_outline)),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            obscureText: true,
                            controller: passwordcontroller,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Password",
                                prefixIcon: Icon(Icons.password_outlined)),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordPage()));
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (mailcontroller.text != "" &&
                                passwordcontroller.text != "") {
                              setState(() {
                                email = mailcontroller.text;
                                password = passwordcontroller.text;
                              });
                              userLogin();
                            }
                          },
                          child: Center(
                            child: Container(
                              width: 200,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffef2b39),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                  child: Text(
                                "Log In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have account?",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()));
                                },
                                child: Text(
                                  "SignUp",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                          ],
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
