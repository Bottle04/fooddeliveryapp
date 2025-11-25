import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/bottomnav.dart';
import 'package:fooddeliveryapp/pages/login.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:random_string/random_string.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  registration() async {
    if (namecontroller.text.isNotEmpty &&
        mailcontroller.text.isNotEmpty &&
        passwordcontroller.text.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String Id = randomAlphaNumeric(10);

        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "Email": mailcontroller.text,
          "Id": Id,
          "Wallet": "0",
        };

        await SharedpreferenceHelper().saveUserEmail(email);
        await SharedpreferenceHelper().saveUserName(namecontroller.text);
        await SharedpreferenceHelper().saveUserId(Id);
        await DatabaseMethods().addUserDetails(userInfoMap, Id);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            )));

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BottomNav()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.message.toString(),
              style: TextStyle(fontSize: 16),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- HEADER ----------
            Container(
              height: MediaQuery.of(context).size.height / 2.5,
              padding: EdgeInsets.only(top: 30.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xffffefbf),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "images/pan.png",
                    height: 180,
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

            // ---------- FORM SIGNUP ----------
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3.2,
                left: 20.0,
                right: 20.0,
              ),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    // padding dưới 20.0 vẫn có thể gây lỗi overflow, nhưng tôi giữ lại vì nó đã được tối ưu từ lần trước
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.0),
                        Center(
                          child: Text(
                            "SignUp",
                            style: AppWidget.HeadlineTextFeildStyle(),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text("Name", style: AppWidget.SignUpTextFeildStyle()),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: namecontroller,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Name",
                                prefixIcon: Icon(Icons.person_outline)),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("Email", style: AppWidget.SignUpTextFeildStyle()),
                        SizedBox(height: 5),
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
                        SizedBox(height: 20),
                        Text("Password",
                            style: AppWidget.SignUpTextFeildStyle()),
                        SizedBox(height: 5),
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
                        SizedBox(height: 30),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (namecontroller.text.isNotEmpty &&
                                  mailcontroller.text.isNotEmpty &&
                                  passwordcontroller.text.isNotEmpty) {
                                setState(() {
                                  name = namecontroller.text;
                                  email = mailcontroller.text;
                                  password = passwordcontroller.text;
                                });
                                registration();
                              }
                            },
                            child: Container(
                              width: 200,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xffef2b39),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                  child: Text(
                                "Sign Up",
                                style: AppWidget.boldwhiteTextFeildStyle(),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ❗ ĐÃ SỬA: Bọc Text dài bằng Flexible để khắc phục lỗi tràn ngang
                            Flexible(
                              child: Text(
                                "Already have an account?",
                                style: AppWidget.SimpleTextFeildStyle(),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LogIn()));
                                },
                                child: Text(
                                  "LogIn",
                                  style: AppWidget.boldTextFeildStyle(),
                                ))
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
