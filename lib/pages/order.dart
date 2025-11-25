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
  bool isLoading = true; // trạng thái loading

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  Future<void> getSharedPref() async {
    id = await SharedpreferenceHelper().getUserId();
  }

  Future<void> getOnTheLoad() async {
    setState(() {
      isLoading = true;
    });

    await getSharedPref();

    if (id != null) {
      orderStream = await DatabaseMethods().getUserOrders(id!);
    } else {
      print("User ID is null! Cannot fetch orders.");
      orderStream = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget allOrders() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderStream == null) {
      return const Center(child: Text("No orders found or user not logged in"));
    }

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
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Material(
                elevation: 3.0,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 5.0),
                      // [FIX LỖI]: Row Address
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Căn lề trái
                        children: [
                          const SizedBox(width: 10.0), // Padding trái
                          const Icon(Icons.location_on_outlined,
                              color: Color(0xffef2b39)),
                          const SizedBox(width: 10.0),
                          Flexible(
                            // Bọc Text bằng Flexible để co giãn
                            child: Text(
                              ds["Address"] ?? "",
                              style: AppWidget.SimpleTextFeildStyle(),
                              overflow: TextOverflow.ellipsis, // Thêm dấu ...
                            ),
                          ),
                          const SizedBox(width: 10.0), // Padding phải
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Image.asset(
                            ds["FoodImage"] ?? "",
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ds["FoodName"] ?? "",
                                  style: AppWidget.boldTextFeildStyle()),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered,
                                      color: Color(0xffef2b39)),
                                  const SizedBox(width: 10.0),
                                  Text(ds["Quantity"] ?? "0",
                                      style: AppWidget.boldTextFeildStyle()),
                                  const SizedBox(width: 30.0),
                                  const Icon(Icons.monetization_on,
                                      color: Color(0xffef2b39)),
                                  const SizedBox(width: 10.0),
                                  Text("\$${ds["Total"] ?? "0"}",
                                      style: AppWidget.boldTextFeildStyle()),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                "${ds["Status"] ?? ""}!",
                                style: const TextStyle(
                                  color: Color(0xffef2b39),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
      body: Container(
        margin: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Orders", style: AppWidget.HeadlineTextFeildStyle()),
              ],
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    Expanded(child: allOrders()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
