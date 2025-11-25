import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/Admin/home_admin.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class AdminLogIn extends StatefulWidget {
  const AdminLogIn({super.key});

  @override
  State<AdminLogIn> createState() => _AdminLogInState();
}

class _AdminLogInState extends State<AdminLogIn> {
  TextEditingController usernamecontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bọc toàn bộ body bằng SingleChildScrollView
      body: SingleChildScrollView(
        child: Container(
          // Đặt chiều cao bằng chiều cao màn hình để giữ bố cục Stack
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
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
                    // ĐÃ BỎ DÒNG CỐ ĐỊNH CHIỀU CAO: height: MediaQuery.of(context).size.height / 2.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        Center(
                          child: Text(
                            "Admin",
                            style: AppWidget.HeadlineTextFeildStyle(),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          "Username",
                          style: AppWidget.SignUpTextFeildStyle(),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: usernamecontroller,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Username",
                                prefixIcon: Icon(Icons.person_outline)),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Password",
                          style: AppWidget.SignUpTextFeildStyle(),
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
                          height: 30.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            loginAdmin();
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
                                "LogIn",
                                style: AppWidget.boldwhiteTextFeildStyle(),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
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

  loginAdmin() {
    FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
      snapshot.docs.forEach((result) {
        if (result.data()['username'] != usernamecontroller.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Your username is not correct",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (result.data()['password'] != passwordcontroller.text) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Your password is not correct",
                style: TextStyle(fontSize: 18.0),
              )));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeAdmin()));
        }
      });
    });
  }
}
