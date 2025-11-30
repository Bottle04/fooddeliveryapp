// [TẠO FILE MỚI: Admin/manage_menu.dart]

import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/Admin/add_food.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class ManageMenu extends StatefulWidget {
  const ManageMenu({super.key});

  @override
  State<ManageMenu> createState() => _ManageMenuState();
}

class _ManageMenuState extends State<ManageMenu> {
  final List<String> categories = ['Pizza', 'Burger', 'Chinese', 'Mexican'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 60.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage Menu", style: AppWidget.HeadlineTextFeildStyle()),
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

            // Nút Thêm sản phẩm mới (Điều hướng đến AddFood)
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
                  child: Text("ADD NEW PRODUCT",
                      style: AppWidget.boldwhiteTextFeildStyle()),
                ),
              ),
            ),

            SizedBox(height: 30.0),
            Text("Edit/Delete by Category:",
                style: AppWidget.boldTextFeildStyle()),
            SizedBox(height: 10.0),

            // Danh sách các Category để xem/chỉnh sửa
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                          const Icon(Icons.folder, color: Color(0xffef2b39)),
                      title: Text(categories[index],
                          style: AppWidget.boldTextFeildStyle()),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 15.0),
                      onTap: () {
                        // TODO: Triển khai màn hình chỉnh sửa danh sách sản phẩm tại đây
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Viewing products in ${categories[index]}. Implement EditFoodList here!")));
                      },
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
