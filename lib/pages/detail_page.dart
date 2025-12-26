import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:random_string/random_string.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart'; // Import thư viện format ngày giờ

class DetailPage extends StatefulWidget {
  final String image;
  final String name;
  final String price;
  final String description;
  final String id;
  final String category;

  const DetailPage({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.description,
    required this.id,
    required this.category,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController noteController = TextEditingController();

  String? name, id, email, address, wallet;
  int quantity = 1, totalprice = 0;

  String deliveryType = "At Restaurant";
  String? selectedTable;
  double shippingFee = 0;
  final double shopLat = 16.0544;
  final double shopLog = 108.2485;

  @override
  void initState() {
    totalprice = int.parse(widget.price);
    getthesharedpref();
    getUserWallet();
    super.initState();
  }

  getthesharedpref() async {
    name = await SharedpreferenceHelper().getUserName();
    id = await SharedpreferenceHelper().getUserId();
    email = await SharedpreferenceHelper().getUserEmail();
    address = await SharedpreferenceHelper().getUserAddress();
    addresscontroller.text = address ?? "";
    setState(() {});
  }

  getUserWallet() async {
    await getthesharedpref();
    if (email != null) {
      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserWalletbyemail(email!);
      if (querySnapshot.docs.isNotEmpty) {
        wallet = querySnapshot.docs[0].get('Wallet');
      }
    }
    setState(() {});
  }

  Future<void> calculateOSMShipping(String userAddress) async {
    try {
      List<Location> locations = await locationFromAddress(userAddress);
      if (locations.isNotEmpty) {
        final Distance distance = const Distance();
        double distanceInMeters = distance.as(
          LengthUnit.Meter,
          LatLng(shopLat, shopLog),
          LatLng(locations.first.latitude, locations.first.longitude),
        );

        double km = distanceInMeters / 1000;
        setState(() {
          if (km <= 2.0) {
            shippingFee = 0;
          } else {
            shippingFee = (km - 2.0).ceil() * 0.5;
          }
        });
      }
    } catch (e) {
      print("Error Geocoding: $e");
      setState(() {
        shippingFee = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Biến hiển thị tổng tiền tạm tính (cho UI)
    double finalTotal = totalprice.toDouble() + shippingFee;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xffef2b39),
                        borderRadius: BorderRadius.circular(30)),
                    child: const Icon(Icons.arrow_back,
                        size: 30.0, color: Colors.white)),
              ),
              const SizedBox(height: 10.0),
              Center(
                  child: Image.network(widget.image,
                      height: MediaQuery.of(context).size.height / 3,
                      fit: BoxFit.contain)),
              const SizedBox(height: 20.0),
              Text(widget.name, style: AppWidget.HeadlineTextFeildStyle()),
              Text("\$${widget.price}", style: AppWidget.priceTextFeildStyle()),
              const SizedBox(height: 20.0),
              Text(widget.description,
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 15.0)),
              const SizedBox(height: 20.0),
              Text("Special Instructions",
                  style: AppWidget.SimpleTextFeildStyle()),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "E.g. No onions, extra spicy...",
                    hintStyle: TextStyle(fontSize: 14.0),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              Text("Quantity", style: AppWidget.SimpleTextFeildStyle()),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      quantity++;
                      totalprice += int.parse(widget.price);
                      setState(() {});
                    },
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: const Color(0xffef2b39),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 30.0)),
                  ),
                  const SizedBox(width: 20.0),
                  Text(quantity.toString(),
                      style: AppWidget.HeadlineTextFeildStyle()),
                  const SizedBox(width: 20.0),
                  GestureDetector(
                    onTap: () {
                      if (quantity > 1) {
                        quantity--;
                        totalprice -= int.parse(widget.price);
                        setState(() {});
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: const Color(0xffef2b39),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.remove,
                            color: Colors.white, size: 30.0)),
                  ),
                ],
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 60,
                      width: 130,
                      decoration: BoxDecoration(
                          color: const Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                          child: Text("\$${finalTotal.toStringAsFixed(1)}",
                              style: AppWidget.boldwhiteTextFeildStyle())),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        bool? isConfirm = await openBox();

                        if (isConfirm == true) {
                          // Tính toán lại tổng tiền thực tế (bao gồm phí ship nếu có)
                          double realTotal =
                              totalprice.toDouble() + shippingFee;

                          if (deliveryType == "At Restaurant" &&
                              selectedTable == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Select a table!")));
                            return;
                          }
                          if (deliveryType == "Take Away" &&
                              addresscontroller.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Enter address!")));
                            return;
                          }

                          double userWallet = double.parse(wallet ?? "0");

                          // Kiểm tra số dư ví
                          if (userWallet >= realTotal) {
                            // 1. Cập nhật số dư ví mới
                            double updatedwallet = userWallet - realTotal;
                            await DatabaseMethods().updateUserWallet(
                                updatedwallet.toStringAsFixed(1), id!);

                            // 2. GHI LỊCH SỬ GIAO DỊCH (LOẠI TRỪ TIỀN - DEBIT)
                            String date = DateFormat("yyyy-MM-dd HH:mm:ss")
                                .format(DateTime.now());
                            Map<String, dynamic> transactionMap = {
                              "Amount": realTotal.toStringAsFixed(1),
                              "Date": date,
                              "Type": "Debit" // Đánh dấu là chi tiêu
                            };
                            await DatabaseMethods()
                                .addUserTransaction(transactionMap, id!);

                            // 3. Tạo đơn hàng
                            String orderId = randomAlphaNumeric(10);
                            Map<String, dynamic> userOrderMap = {
                              "Name": name,
                              "Id": id,
                              "Quantity": quantity.toString(),
                              "Total": realTotal.toStringAsFixed(1),
                              "Email": email,
                              "FoodName": widget.name,
                              "FoodImage": widget.image,
                              "OrderId": orderId,
                              "Status": "Pending",
                              "OrderTime": FieldValue.serverTimestamp(),
                              "DeliveryType": deliveryType,
                              "Note": noteController.text,
                              "TableNumber": deliveryType == "At Restaurant"
                                  ? selectedTable
                                  : "N/A",
                              "Address": deliveryType == "Take Away"
                                  ? addresscontroller.text
                                  : "18 Phan Tứ, Đà Nẵng",
                              "ShippingFee": shippingFee.toStringAsFixed(1),
                              "FoodId": widget.id,
                              "Category": widget.category,
                            };

                            await DatabaseMethods().addUserOrderDetails(
                                userOrderMap, id!, orderId);
                            await DatabaseMethods()
                                .addAdminOrderDetails(userOrderMap, orderId);

                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.green,
                                    content:
                                        Text("Order Placed Successfully!")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Insufficient Balance")));
                          }
                        }
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text("ORDER NOW",
                                  style: AppWidget.whiteTextFeildStyle())),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> openBox() => showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
            builder: (context, setStateDialog) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: const BoxDecoration(
                        color: Color(0xFF008080),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Delivery Options",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context, false),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RadioListTile(
                      activeColor: const Color(0xFF008080),
                      title: const Text("At Restaurant"),
                      secondary: const Icon(Icons.restaurant,
                          color: Color(0xFF008080)),
                      value: "At Restaurant",
                      groupValue: deliveryType,
                      onChanged: (val) {
                        setStateDialog(() {
                          deliveryType = val.toString();
                          shippingFee = 0;
                        });
                        setState(() {});
                      },
                    ),
                    if (deliveryType == "At Restaurant")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: DropdownButton<String>(
                          hint: const Text("Select Table (1-8)"),
                          value: selectedTable,
                          isExpanded: true,
                          items: List.generate(8, (i) => "Table ${i + 1}")
                              .map((t) =>
                                  DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (val) {
                            setStateDialog(() => selectedTable = val);
                            setState(() {});
                          },
                        ),
                      ),
                    const Divider(indent: 20, endIndent: 20),
                    RadioListTile(
                      activeColor: const Color(0xFF008080),
                      title: const Text("Take Away"),
                      secondary: const Icon(Icons.delivery_dining,
                          color: Color(0xFF008080)),
                      value: "Take Away",
                      groupValue: deliveryType,
                      onChanged: (val) {
                        setStateDialog(() => deliveryType = val.toString());
                        setState(() {});
                      },
                    ),
                    if (deliveryType == "Take Away")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            const Text("Shop: 18 Phan Tứ, Đà Nẵng",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: addresscontroller,
                              decoration: InputDecoration(
                                hintText: "Enter address",
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF008080)),
                                onPressed: () async {
                                  await calculateOSMShipping(
                                      addresscontroller.text);
                                  setStateDialog(() {});
                                  setState(() {});
                                },
                                child: const Text("Calculate Fee",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            if (shippingFee > 0)
                              Text("Fee: \$${shippingFee.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Center(
                            child: Text("CONFIRM",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ));
}
