// file: manage_menu.dart

import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/Admin/add_food.dart';
import 'package:fooddeliveryapp/Admin/edit_food_list.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class ManageMenu extends StatefulWidget {
  const ManageMenu({super.key});

  @override
  State<ManageMenu> createState() => _ManageMenuState();
}

class _ManageMenuState extends State<ManageMenu> {
  final List<String> categories = ['Pizza', 'Burger', 'Chinese', 'Mexican'];

  // Biến trạng thái để kiểm soát việc hiển thị danh sách category
  bool _isCategoryListVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 60.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage Products", style: AppWidget.HeadlineTextFeildStyle()),
            SizedBox(height: 20.0),

            // Nút Quay lại
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xffef2b39),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            SizedBox(height: 20.0),

            // 1. Nút Thêm sản phẩm mới (ADD NEW PRODUCT)
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddFood()));
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xffef2b39),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  // Thêm '\n' và textAlign để đảm bảo cùng chiều cao với nút dưới
                  child: Text("ADD NEW\nPRODUCT",
                      textAlign: TextAlign.center,
                      style: AppWidget.boldwhiteTextFeildStyle()),
                ),
              ),
            ),

            SizedBox(height: 30.0),

            // 2. Mục Edit/Delete by Category (Đã tối ưu để có cùng kích thước)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCategoryListVisible = !_isCategoryListVisible;
                });
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xffef2b39), // Màu đỏ nhất quán
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Thêm '\n' và textAlign để cân bằng chiều cao
                      Text("EDIT/DELETE BY\nCATEGORY",
                          textAlign: TextAlign.center,
                          style: AppWidget.boldwhiteTextFeildStyle()),

                      // Icon để báo hiệu trạng thái mở/đóng
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                            _isCategoryListVisible
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),

            // 3. Danh sách các Category (Chỉ hiển thị khi mở, đã làm nhỏ lại)
            Expanded(
              child: Visibility(
                visible: _isCategoryListVisible,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditFoodList(
                                      category: categories[index])));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10), // Kích thước nhỏ hơn
                          decoration: BoxDecoration(
                            color: Color(0xffef2b39),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categories[index],
                                style: AppWidget.whiteTextFeildStyle(),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 20.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
