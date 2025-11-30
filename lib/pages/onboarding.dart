import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/signup.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // Thêm padding ngang để nội dung không chạm mép màn hình
        margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            // FIX LỖI BỐ CỤC: Bọc Image bằng Expanded để nó chiếm không gian còn lại
            Expanded(
              child: Image.asset(
                "images/onboard.png",
                fit: BoxFit.contain, // Đảm bảo hình ảnh co giãn đúng
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "The Fastest\nFood Delivery",
              textAlign: TextAlign.center,
              style: AppWidget.HeadlineTextFeildStyle(),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Craving something delicious?\nOrder now and get your favorites\ndelivered fast!",
              textAlign: TextAlign.center,
              style: AppWidget.SimpleTextFeildStyle(),
            ),
            SizedBox(
              height: 30.0,
            ), // Khoảng cách trước nút
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignUp()));
              },
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    color: Color(0xff8c592a),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ) // Thêm khoảng cách an toàn dưới cùng
          ],
        ),
      ),
    );
  }
}
