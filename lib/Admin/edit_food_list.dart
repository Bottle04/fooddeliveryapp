// lib/Admin/edit_food_list.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart'; // Import đã được thêm
import 'package:fooddeliveryapp/service/widget_support.dart';

class EditFoodList extends StatefulWidget {
  final String category;

  const EditFoodList({super.key, required this.category});

  @override
  State<EditFoodList> createState() => _EditFoodListState();
}

class _EditFoodListState extends State<EditFoodList> {
  Stream<QuerySnapshot>? foodStream;

  getOnTheLoad() async {
    // Sử dụng DatabaseMethods để lấy danh sách món ăn theo Category
    foodStream = await DatabaseMethods().getFoodItems(widget.category);
    setState(() {});
  }

  @override
  void initState() {
    getOnTheLoad();
    super.initState();
  }

  // Hàm xóa sản phẩm
  Future<void> deleteFoodItem(String docId) async {
    // Gọi hàm deleteFoodItem từ DatabaseMethods (đã thêm ở file database.dart)
    await DatabaseMethods().deleteFoodItem(widget.category, docId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Item deleted successfully!")));
  }

  // Hàm hiển thị danh sách sản phẩm
  Widget allFoodItems() {
    if (foodStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: foodStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];
            String docId = ds.id;
            String name = ds["Name"] ?? "No Name";
            String price = ds["Price"] ?? "0";
            String image = ds["Image"] ?? "";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2.0,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("images/pan.png",
                          height: 60, width: 60, fit: BoxFit.cover);
                    },
                  ),
                ),
                title: Text(name, style: AppWidget.boldTextFeildStyle()),
                subtitle:
                    Text("\$${price}", style: AppWidget.priceTextFeildStyle()),

                // Nút chỉnh sửa và xóa
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút CHỈNH SỬA (TODO: Triển khai màn hình EditFoodDetails)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Implement navigation to EditFoodDetails here
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Editing: $name. (Not yet implemented)")));
                      },
                    ),
                    // Nút XÓA (Đã triển khai logic)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Xác nhận trước khi xóa
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: Text(
                                "Are you sure you want to delete '$name'?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          deleteFoodItem(docId);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage ${widget.category}",
            style: AppWidget.HeadlineTextFeildStyle()),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffef2b39)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: allFoodItems(),
      ),
    );
  }
}
