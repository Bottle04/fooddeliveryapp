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

  @override
  void initState() {
    super.initState();
    getUserWallet();
  }

  getthesharedpref() async {
    email = await SharedpreferenceHelper().getUserEmail();
    id = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  getUserWallet() async {
    await getthesharedpref();

    if (id != null) {
      walletStream = await DatabaseMethods().getUserTransactions(id!);
    }

    if (email != null) {
      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserWalletbyemail(email!);

      if (querySnapshot.docs.isEmpty) {
        await DatabaseMethods().updateUserWallet("0", id!);
        wallet = "0";
      } else {
        wallet = "${querySnapshot.docs.first["Wallet"]}";
      }
    }
    setState(() {});
  }

  Widget allTransactions() {
    return StreamBuilder(
      stream: walletStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No Transactions"));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(ds["Date"], style: AppWidget.HeadlineTextFeildStyle()),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Amount added to wallet"),
                        Text(
                          "\$${ds["Amount"]}",
                          style: const TextStyle(
                              color: Color(0xffef2b39),
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                ],
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
      body: wallet == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  /// 🔙 HEADER WITH BACK BUTTON
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context); // Thoát về màn hình chính
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Wallet",
                            style: AppWidget.HeadlineTextFeildStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          walletBox(),
                          const SizedBox(height: 40),
                          quickAddButtons(),
                          const SizedBox(height: 30),
                          addMoneyButton(),
                          const SizedBox(height: 20),
                          Expanded(child: historyBox()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget walletBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Image.asset("images/wallet.png", height: 80, width: 80),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Wallet", style: AppWidget.boldTextFeildStyle()),
                    Text("\$${wallet!}",
                        style: AppWidget.HeadlineTextFeildStyle()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickAddButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        quickAdd("\$50", "50"),
        quickAdd("\$100", "100"),
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(label, style: AppWidget.priceTextFeildStyle()),
        ),
      ),
    );
  }

  Widget addMoneyButton() {
    return GestureDetector(
      onTap: () => openBox(),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xffef2b39),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text("Add Money", style: AppWidget.boldwhiteTextFeildStyle()),
        ),
      ),
    );
  }

  Widget historyBox() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text("Your Transactions", style: AppWidget.boldTextFeildStyle()),
          const SizedBox(height: 20),
          Expanded(child: allTransactions()),
        ],
      ),
    );
  }

  // ================= STRIPE ==================

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent?['client_secret'],
          merchantDisplayName: 'Food Delivery',
        ),
      );

      displayPaymentSheet(amount);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      int currentBalance = int.tryParse(wallet ?? "0") ?? 0;
      int addAmount = int.tryParse(amount) ?? 0;
      int newBalance = currentBalance + addAmount;

      await DatabaseMethods().updateUserWallet(newBalance.toString(), id!);

      String date = DateFormat("dd MMM").format(DateTime.now());
      await DatabaseMethods()
          .addUserTransaction({"Amount": amount, "Date": date}, id!);

      setState(() {
        wallet = newBalance.toString();
      });

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Payment Successful"),
            ],
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(content: Text("Payment Cancelled")),
      );
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (int.parse(amount) * 100).toString(),
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
      debugPrint(err.toString());
    }
  }

  Future openBox() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Amount"),
              TextField(
                controller: amountcontroller,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (amountcontroller.text.isNotEmpty) {
                    makePayment(amountcontroller.text);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      );
}
