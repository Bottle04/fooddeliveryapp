import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  getontheload() async {
    orderStream = await DatabaseMethods().getAdminOrders();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Stream? orderStream;

  Widget allOrders() {
    return StreamBuilder(
        stream: orderStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 20.0),
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: Column(children: [
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: Color(0xffef2b39)),
                                SizedBox(
                                  width: 10.0,
                                ),
                                // ĐỊA CHỈ: Bọc trong Flexible để không tràn
                                Flexible(
                                  child: Text(
                                    ds["Address"],
                                    style: AppWidget.SimpleTextFeildStyle(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                            Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh sản phẩm
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    ds["FoodImage"],
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset("images/pan.png",
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                // Chi tiết đơn hàng: BỌC TRONG EXPANDED (đã làm)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TÊN MÓN ĂN
                                      Text(
                                        ds["FoodName"],
                                        style: AppWidget.boldTextFeildStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      // Quantity and Total
                                      Row(
                                        children: [
                                          Icon(Icons.format_list_numbered,
                                              color: Color(0xffef2b39)),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text(
                                            ds["Quantity"],
                                            style:
                                                AppWidget.boldTextFeildStyle(),
                                          ),
                                          SizedBox(
                                            width: 30.0,
                                          ),
                                          Icon(Icons.monetization_on,
                                              color: Color(0xffef2b39)),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text(
                                            "\$" + ds["Total"],
                                            style:
                                                AppWidget.boldTextFeildStyle(),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      // TÊN KHÁCH HÀNG
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              color: Color(0xffef2b39)),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Flexible(
                                            // Bọc trong Flexible
                                            child: Text(
                                              ds["Name"],
                                              style: AppWidget
                                                  .SimpleTextFeildStyle(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      // EMAIL KHÁCH HÀNG
                                      Row(
                                        children: [
                                          Icon(Icons.mail,
                                              color: Color(0xffef2b39)),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Flexible(
                                            // Bọc trong Flexible
                                            child: Text(
                                              ds["Email"],
                                              style: AppWidget
                                                  .SimpleTextFeildStyle(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        ds["Status"] + "!",
                                        style: TextStyle(
                                            color: Color(0xffef2b39),
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await DatabaseMethods()
                                              .updateAdminOrder(ds.id);
                                          await DatabaseMethods()
                                              .updateUserOrder(ds["Id"], ds.id);
                                        },
                                        child: Container(
                                          width: 100,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                              child: Text(
                                            "Delivered",
                                            style:
                                                AppWidget.whiteTextFeildStyle(),
                                          )),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6,
                  ),
                  Text(
                    "All Orders",
                    style: AppWidget.HeadlineTextFeildStyle(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xFFececf8),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: allOrders()),
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
