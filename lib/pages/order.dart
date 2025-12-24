import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    setState(() {
      isLoading = false;
    });
  }

  Widget allOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No orders yet"));

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];
            bool isAtRestaurant = ds["DeliveryType"] == "At Restaurant";

            Timestamp? orderTimestamp = ds["OrderTime"] as Timestamp?;
            String formattedTime = orderTimestamp != null
                ? orderTimestamp.toDate().toString().split('.').first
                : "N/A";

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
                      // HIỂN THỊ THÔNG TIN ĐỊA ĐIỂM
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
                                  ? "At Table: ${ds["TableNumber"]}"
                                  : "Ship to: ${ds["Address"]}",
                              style: AppWidget.SimpleTextFeildStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isAtRestaurant && ds["ShippingFee"] != "0.0")
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 35.0),
                            child: Text("Shipping Fee: \$${ds["ShippingFee"]}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blue)),
                          ),
                        ),
                      const Divider(),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(ds["FoodImage"] ?? "",
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
                                Text(ds["FoodName"] ?? "",
                                    style: AppWidget.boldTextFeildStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                    "Qty: ${ds["Quantity"]} | Total: \$${ds["Total"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                Text("Time: $formattedTime",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(ds["Status"] + "!",
                                    style: const TextStyle(
                                        color: Color(0xffef2b39),
                                        fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFececf8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("My Orders", style: AppWidget.HeadlineTextFeildStyle()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allOrders(),
    );
  }
}
