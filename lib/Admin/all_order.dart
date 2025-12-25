import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:audioplayers/audioplayers.dart'; // Thư viện âm thanh

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Stream? orderStream;
  int _currentOrderCount = 0; // Lưu số lượng đơn hàng hiện tại
  final AudioPlayer _audioPlayer = AudioPlayer(); // Khởi tạo trình phát nhạc

  getontheload() async {
    orderStream = await DatabaseMethods().getAdminOrders();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  // Hàm phát chuông báo khi có đơn hàng mới
  Future<void> _playNotificationSound() async {
    try {
      // Lưu ý: file mp3 phải nằm trong assets và đã khai báo trong pubspec.yaml
      await _audioPlayer.play(AssetSource('notification.mp3'));
    } catch (e) {
      print("Lỗi phát âm thanh: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Giải phóng bộ nhớ
    super.dispose();
  }

  Widget allOrders() {
    return StreamBuilder(
        stream: orderStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // logic THÔNG BÁO ĐƠN HÀNG MỚI
          int newCount = snapshot.data.docs.length;

          // Nếu đây không phải lần đầu load trang và số đơn hàng tăng lên
          if (_currentOrderCount != 0 && newCount > _currentOrderCount) {
            _playNotificationSound(); // Phát chuông báo

            // Hiển thị thông báo nổi (SnackBar)
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("🔔 Bạn có đơn hàng mới!"),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 4),
              ));
            });
          }
          _currentOrderCount = newCount; // Cập nhật số lượng mới

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                Map<String, dynamic> data = ds.data() as Map<String, dynamic>;

                Timestamp? orderTimestamp = data["OrderTime"] as Timestamp?;
                String formattedTime = orderTimestamp != null
                    ? orderTimestamp.toDate().toString().split('.').first
                    : "N/A";

                bool hasDeliveryType = data.containsKey("DeliveryType");
                bool isAtRestaurant =
                    hasDeliveryType && data["DeliveryType"] == "At Restaurant";

                bool isDelivered = data["Status"] == "Delivered";

                return Container(
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundColor: const Color(0xffef2b39),
                              radius: 12,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                isAtRestaurant
                                    ? Icons.restaurant
                                    : Icons.delivery_dining,
                                color: const Color(0xffef2b39)),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: Text(
                                isAtRestaurant
                                    ? "DINING: ${data["TableNumber"] ?? "N/A"}"
                                    : "DELIVER: ${data["Address"] ?? "Old Order"}",
                                style: AppWidget.boldTextFeildStyle().copyWith(
                                    color: isAtRestaurant
                                        ? Colors.green
                                        : Colors.blue),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        if (hasDeliveryType &&
                            data["DeliveryType"] == "Take Away")
                          Text("Shipping Fee: \$${data["ShippingFee"] ?? "0"}",
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.grey, size: 20),
                              const SizedBox(width: 10.0),
                              Text(formattedTime,
                                  style: AppWidget.SimpleTextFeildStyle()),
                            ],
                          ),
                        ),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10.0),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                data["FoodImage"] ?? "",
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset("images/pan.png",
                                        height: 90, width: 90),
                              ),
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
                                      style: AppWidget.SimpleTextFeildStyle()),

                                  // HIỂN THỊ GHI CHÚ TỪ KHÁCH HÀNG
                                  if (data.containsKey("Note") &&
                                      data["Note"].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                          children: [
                                            const TextSpan(
                                                text: "Note: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent)),
                                            TextSpan(
                                                text: "${data["Note"]}",
                                                style: const TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic)),
                                          ],
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 16, color: Colors.orange),
                                      const SizedBox(width: 5),
                                      Flexible(
                                          child: Text(data["Name"] ?? "User",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),

                                  Text("${data["Status"]}!",
                                      style: TextStyle(
                                          color: isDelivered
                                              ? Colors.green
                                              : const Color(0xffef2b39),
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10.0),

                                  if (!isDelivered)
                                    GestureDetector(
                                      onTap: () async {
                                        await DatabaseMethods()
                                            .updateAdminOrder(ds.id);
                                        if (data["Id"] != null &&
                                            data["OrderId"] != null) {
                                          await DatabaseMethods()
                                              .updateUserOrder(
                                                  data["Id"], data["OrderId"]);
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                              "Order marked as Delivered!"),
                                        ));
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text("Mark Delivered",
                                                style: AppWidget
                                                        .whiteTextFeildStyle()
                                                    .copyWith(fontSize: 12))),
                                      ),
                                    )
                                  else
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 20),
                                        SizedBox(width: 5),
                                        Text("Completed",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  const SizedBox(height: 15.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(30)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Text("Management", style: AppWidget.HeadlineTextFeildStyle())
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Color(0xFFececf8),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    Expanded(child: allOrders()),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
