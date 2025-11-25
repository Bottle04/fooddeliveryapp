import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fooddeliveryapp/service/constant.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  TextEditingController amountcontroller = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  String? email, wallet = "0", id;

  Stream? walletStream;

  // Lấy email + id
  getthesharedpref() async {
    email = await SharedpreferenceHelper().getUserEmail();
    id = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  // Lấy số dư ví + giao dịch
  getUserWallet() async {
    await getthesharedpref();

    // Stream giao dịch
    walletStream = await DatabaseMethods().getUserTransactions(id!);

    // Query ví user
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserWalletbyemail(email!);

    // Nếu chưa có ví → tạo ví mới
    if (querySnapshot.docs.isEmpty) {
      await DatabaseMethods().updateUserWallet("0", id!);
      wallet = "0";
    } else {
      wallet = "${querySnapshot.docs.first["Wallet"]}";
    }

    print("WALLET = $wallet");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserWallet();
  }

  // Hiển thị lịch sử giao dịch
  Widget allTransactions() {
    return StreamBuilder(
        stream: walletStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.docs.isEmpty) {
            return Center(child: Text("No Transactions"));
          }

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                      color: Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      // Hiển thị Ngày
                      Text(
                        ds["Date"],
                        style: AppWidget.HeadlineTextFeildStyle(),
                      ),
                      SizedBox(width: 20),

                      // [FIX LỖI]: Bọc Column bằng Expanded để tránh tràn ngang
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Amount added to wallet"),
                            Text(
                              "\$${ds["Amount"]}",
                              style: TextStyle(
                                  color: Color(0xffef2b39),
                                  fontSize: 22, // Giảm từ 25 xuống 22
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: wallet == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              margin: EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Center(
                    child: Text("Wallet",
                        style: AppWidget.HeadlineTextFeildStyle()),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          walletBox(),
                          SizedBox(height: 40),
                          quickAddButtons(),
                          SizedBox(height: 30),
                          addMoneyButton(),
                          SizedBox(height: 20),
                          Expanded(child: historyBox())
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  // --- UI: Ví
  Widget walletBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Image.asset("images/wallet.png", height: 80, width: 80),
              SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Wallet", style: AppWidget.boldTextFeildStyle()),
                  Text("\$${wallet!}",
                      style: AppWidget.HeadlineTextFeildStyle())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI: Nút nạp nhanh
  Widget quickAddButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        quickAdd("\$100", "100"),
        quickAdd("\$50", "50"),
        quickAdd("\$200", "200"),
      ],
    );
  }

  Widget quickAdd(String label, String amount) {
    return GestureDetector(
      onTap: () => makePayment(amount),
      child: Container(
        height: 50,
        width: 100,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black45, width: 2),
            borderRadius: BorderRadius.circular(10)),
        child:
            Center(child: Text(label, style: AppWidget.priceTextFeildStyle())),
      ),
    );
  }

  // --- UI: Add Money
  Widget addMoneyButton() {
    return GestureDetector(
      onTap: () => openBox(),
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Color(0xffef2b39), borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text("Add Money", style: AppWidget.boldwhiteTextFeildStyle()),
        ),
      ),
    );
  }

  // --- UI: Lịch sử giao dịch
  Widget historyBox() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text("Your Transactions", style: AppWidget.boldTextFeildStyle()),
          SizedBox(height: 20),
          Expanded(child: allTransactions())
        ],
      ),
    );
  }

  // ----------------- PAYMENT -------------------

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.dark,
              merchantDisplayName: 'Food Delivery'));

      displayPaymentSheet(amount);
    } catch (e) {
      print("Error makePayment: $e");
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      int updatedwallet = int.parse(wallet!) + int.parse(amount);

      await DatabaseMethods().updateUserWallet(updatedwallet.toString(), id!);
      await getUserWallet();

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("dd MMM").format(now);

      await DatabaseMethods()
          .addUserTransaction({"Amount": amount, "Date": formattedDate}, id!);

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Payment Successful")
                  ],
                ),
              ));

      paymentIntent = null;
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text("Payment Cancelled")));
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (err) {
      print("err charging user: $err");
    }
  }

  calculateAmount(String amount) {
    return (int.parse(amount) * 100).toString();
  }

  // Popup nhập số tiền
  Future openBox() => showDialog(
      context: context,
      builder: (_) => AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.cancel)),
                      SizedBox(width: 30),
                      Text("Add amount",
                          style: TextStyle(
                              color: Color(0xff008080),
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Enter Amount"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: 2),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: amountcontroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Amount"),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      makePayment(amountcontroller.text);
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Color(0xFF008080),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text("Add",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
}
