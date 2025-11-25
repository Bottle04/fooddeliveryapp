import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/onboarding.dart';
import 'package:fooddeliveryapp/service/auth.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name, email;

  getthesharedpref() async {
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return name == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            // [FIX 1]: Bọc bằng SingleChildScrollView để cuộn dọc (Fix BOTTOM OVERFLOWED)
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 40.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Profile",
                          style: AppWidget.HeadlineTextFeildStyle(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    // [FIX 2]: Xóa Expanded để tránh lỗi cuộn lồng nhau
                    Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Color(0xFFececf8),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: Column(children: [
                          SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            height: 150,
                            width: 150,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: Image.asset(
                                  "images/boy.jpg",
                                  fit: BoxFit.cover,
                                )),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          // Thẻ Name
                          Container(
                            margin: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: Color(0xffef2b39),
                                    size: 35.0,
                                  ),
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        name!,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          // Thẻ Email
                          Container(
                            margin: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(children: [
                                  Icon(
                                    Icons.mail_outline,
                                    color: Color(0xffef2b39),
                                    size: 35.0,
                                  ),
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      // [FIX 3]: Giới hạn chiều rộng của Text(email!) để tránh tràn ngang
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                150,
                                        child: Text(
                                          email!,
                                          overflow: TextOverflow
                                              .ellipsis, // Thêm ... nếu text quá dài
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 35.0,
                          ),
                          // Thẻ LogOut
                          GestureDetector(
                            onTap: () async {
                              await AuthMethods().SignOut();
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Onboarding()));
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 20.0,
                                      bottom: 20.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(children: [
                                    Icon(
                                      Icons.logout,
                                      color: Color(0xffef2b39),
                                      size: 35.0,
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Text(
                                      "LogOut",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Color(0xffef2b39),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 35.0,
                          ),
                          // Thẻ Delete Account
                          GestureDetector(
                            onTap: () async {
                              await AuthMethods().deleteuser();
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Onboarding()));
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 20.0,
                                      bottom: 20.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(children: [
                                    Icon(
                                      Icons.delete,
                                      color: Color(0xffef2b39),
                                      size: 35.0,
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Text(
                                      "Delete Account",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Color(0xffef2b39),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.0, // Khoảng trống an toàn cuối cùng
                          ),
                        ])) // [FIX CÚ PHÁP]: Dấu ngoặc đóng cuối cùng của Container
                  ],
                ),
              ),
            ),
          );
  }
}
