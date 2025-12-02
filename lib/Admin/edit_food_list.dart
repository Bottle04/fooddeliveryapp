// file: edit_food_list.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:fooddeliveryapp/Admin/edit_food_details.dart';

class EditFoodList extends StatefulWidget {
  final String category;

  const EditFoodList({super.key, required this.category});

  @override
  State<EditFoodList> createState() => _EditFoodListState();
}

class _EditFoodListState extends State<EditFoodList> {
  Stream<QuerySnapshot>? foodStream;

  getOnTheLoad() async {
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

            // Ép kiểu an toàn DocumentSnapshot sang Map
            final data = ds.data() as Map<String, dynamic>?;

            String docId = ds.id;
            // Lấy dữ liệu an toàn bằng cách kiểm tra key trong Map
            String name = data?["Name"] ?? "No Name";
            String price = data?["Price"] ?? "0";
            String image = data?["Image"] ?? "";

            // FIX LỖI: Lấy trường Detail an toàn (sử dụng data?[key] thay vì ds[key])
            String detail = data?["Detail"] ?? "No details provided";

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
                    // Nút CHỈNH SỬA
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Điều hướng sang màn hình chỉnh sửa và truyền tất cả dữ liệu
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditFoodDetails(
                                      docId: docId,
                                      category: widget.category,
                                      currentName: name,
                                      currentPrice: price,
                                      currentDetail:
                                          detail, // Đã fix lấy giá trị an toàn
                                      currentImage: image,
                                    )));
                      },
                    ),
                    // Nút XÓA
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
