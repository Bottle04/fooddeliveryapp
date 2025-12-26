import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/bottomnav.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id;
  Stream<QuerySnapshot>? orderStream;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  Future<void> getOnTheLoad() async {
    id = await SharedpreferenceHelper().getUserId();
    if (id != null) {
      orderStream = await DatabaseMethods().getUserOrders(id!);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showRatingDialog(
      BuildContext context, String foodName, String foodId, String category) {
    double selectedRating = 5.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate $foodName"),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            // Giới hạn chiều rộng
            width: double.maxFinite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.all(2.0), // Tạo khoảng cách nhỏ
                  child: GestureDetector(
                    // Dùng GestureDetector thay IconButton để kiểm soát kích thước tốt hơn
                    onTap: () => setState(() => selectedRating = index + 1.0),
                    child: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size:
                          32, // Giảm kích thước icon xuống một chút (mặc định là 24, nhưng IconButton làm nó to ra)
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await DatabaseMethods()
                  .addFoodRating(category, foodId, selectedRating);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cảm ơn bạn đã đánh giá!")));
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget allOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No orders yet"));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];
            Map<String, dynamic> data = ds.data() as Map<String, dynamic>;

            bool isDelivered = data["Status"] == "Delivered";
            bool isAtRestaurant = data["DeliveryType"] == "At Restaurant";

            // Xử lý thời gian
            String formattedTime = "";
            if (data["OrderTime"] != null) {
              try {
                Timestamp t = data["OrderTime"];
                DateTime dt = t.toDate();
                formattedTime = dt.toString().split('.')[0];
              } catch (e) {
                formattedTime = "N/A";
              }
            }

            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      // --- DÒNG 1: ĐỊA CHỈ HOẶC BÀN ---
                      Row(
                        children: [
                          Icon(
                              isAtRestaurant
                                  ? Icons.restaurant
                                  : Icons.location_on,
                              color: const Color(0xffef2b39)),
                          const SizedBox(width: 10.0),
                          Flexible(
                            child: Text(
                              isAtRestaurant
                                  ? "At Table: ${data["TableNumber"] ?? "N/A"}"
                                  : "Ship to: ${data["Address"] ?? "N/A"}",
                              style: AppWidget.SimpleTextFeildStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // --- DÒNG 2: PHÍ SHIP (MỚI THÊM LẠI) ---
                      // Chỉ hiện nếu không phải ăn tại quán VÀ có phí ship > 0
                      if (!isAtRestaurant &&
                          data["ShippingFee"] != null &&
                          data["ShippingFee"] != "0.0" &&
                          data["ShippingFee"] != "0")
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 35.0, top: 5.0),
                            child: Text(
                              "Shipping Fee: \$${data["ShippingFee"]}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ),
                      // ---------------------------------------

                      const Divider(),

                      // --- DÒNG 3: CHI TIẾT MÓN ĂN ---
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(data["FoodImage"] ?? "",
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Image.asset(
                                    "images/pan.png",
                                    height: 80,
                                    width: 80)),
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data["FoodName"] ?? "",
                                    style: AppWidget.boldTextFeildStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                    "Qty: ${data["Quantity"]} | Total: \$${data["Total"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),

                                // Thời gian đặt hàng
                                if (formattedTime.isNotEmpty)
                                  Text(
                                    "Time: $formattedTime",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),

                                Text("${data["Status"]}!",
                                    style: const TextStyle(
                                        color: Color(0xffef2b39),
                                        fontWeight: FontWeight.bold)),

                                // NÚT ĐÁNH GIÁ
                                if (isDelivered)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        String category =
                                            data["Category"] ?? "";
                                        String foodName =
                                            data["FoodName"] ?? "";
                                        String foodId = data["FoodId"] ?? "";

                                        if (category.isNotEmpty &&
                                            foodId.isNotEmpty) {
                                          _showRatingDialog(context, foodName,
                                              foodId, category);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Đơn hàng cũ này thiếu thông tin để đánh giá.")));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10)),
                                      child: const Text("Rate Now",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomNav()));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFececf8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text("My Orders", style: AppWidget.HeadlineTextFeildStyle()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const BottomNav())),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : allOrders(),
      ),
    );
  }
}
