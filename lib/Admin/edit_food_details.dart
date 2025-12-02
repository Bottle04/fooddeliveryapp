// [TẠO FILE MỚI: lib/Admin/edit_food_details.dart]

import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class EditFoodDetails extends StatefulWidget {
  final String docId;
  final String category;
  final String currentName;
  final String currentPrice;
  final String currentDetail;
  final String currentImage;

  const EditFoodDetails({
    super.key,
    required this.docId,
    required this.category,
    required this.currentName,
    required this.currentPrice,
    required this.currentDetail,
    required this.currentImage,
  });

  @override
  State<EditFoodDetails> createState() => _EditFoodDetailsState();
}

class _EditFoodDetailsState extends State<EditFoodDetails> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController detailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    priceController = TextEditingController(text: widget.currentPrice);
    detailController = TextEditingController(text: widget.currentDetail);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    detailController.dispose();
    super.dispose();
  }

  // HÀM UPDATE
  Future<void> updateFoodItemDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Chuẩn bị Map dữ liệu mới
      Map<String, dynamic> updatedFoodMap = {
        "Name": nameController.text.trim(),
        "Price": priceController.text.trim(),
        "Detail": detailController.text.trim(),
      };

      // 2. Gọi hàm cập nhật từ DatabaseMethods
      await DatabaseMethods()
          .updateFoodItem(widget.category, widget.docId, updatedFoodMap);

      // 3. Thông báo thành công và quay lại
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Sản phẩm đã được cập nhật thành công!"),
      ));

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Lỗi cập nhật: $e"),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.currentName}",
            style: AppWidget.HeadlineTextFeildStyle()),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffef2b39)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh hiện tại
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.currentImage,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset("images/pan.png",
                        height: 150, width: 150, fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Input Tên
            Text("Tên món ăn", style: AppWidget.boldTextFeildStyle()),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Nhập tên"),
            ),
            const SizedBox(height: 20),

            // Input Giá
            Text("Giá (\$)", style: AppWidget.boldTextFeildStyle()),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Nhập giá"),
            ),
            const SizedBox(height: 20),

            // Input Chi tiết
            Text("Chi tiết", style: AppWidget.boldTextFeildStyle()),
            TextField(
              controller: detailController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "Nhập chi tiết"),
            ),
            const SizedBox(height: 40),

            // Nút Save Changes
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : updateFoodItemDetails,
                child: Container(
                  // Thiết lập chiều rộng tự động theo nội dung (hoặc một giá trị nhỏ hơn)
                  width: 180,
                  // Giảm padding dọc để nút nhỏ và mỏng lại
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : const Color(0xffef2b39),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height:
                                25, // Cố định chiều cao cho loading indicator
                            width: 25,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            "Save",
                            style: AppWidget.boldwhiteTextFeildStyle(),
                            // Đảm bảo chữ nằm trên một hàng
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
