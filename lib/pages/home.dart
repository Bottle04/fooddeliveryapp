import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/model/burger_model.dart';
import 'package:fooddeliveryapp/model/category_model.dart';
import 'package:fooddeliveryapp/model/pizza_model.dart';
import 'package:fooddeliveryapp/pages/detail_page.dart';
import 'package:fooddeliveryapp/service/burger_data.dart';
import 'package:fooddeliveryapp/service/category_data.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/pizza_data.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  List<PizzaModel> pizza = [];
  List<BurgerModel> burger = [];
  String track = "0";
  bool search = false;
  TextEditingController searchcontroller = new TextEditingController();

  @override
  void initState() {
    categories = getCategories();
    pizza = getPizza();
    burger = getBurger();
    super.initState();
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });

    var CapitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['Name'].startsWith(CapitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 20.0, top: 40.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "images/logo.png",
                      height: 50,
                      width: 110,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      "Order your favourite food!",
                      style: AppWidget.SimpleTextFeildStyle(),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      "images/boy.jpg",
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0),
                    margin: EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: searchcontroller,
                      onChanged: (value) {
                        initiateSearch(value.toUpperCase());
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search food item..."),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10.0),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Color(0xffef2b39),
                      borderRadius: BorderRadius.circular(10)),
                  child: search
                      ? GestureDetector(
                          onTap: () {
                            searchcontroller.text = "";
                            var queryResultSet = [];
                            var tempSearchStore = [];
                            search = false;
                            setState(() {});
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        )
                      : Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30.0,
                        ),
                )
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              height: 70,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(categories[index].name!,
                        categories[index].image!, index.toString());
                  }),
            ),
            SizedBox(
              height: 10.0,
            ),
            search
                ? ListView(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    primary: false,
                    shrinkWrap: true,
                    children: tempSearchStore.map((element) {
                      return buildResultCard(element);
                    }).toList())
                : track == "0"
                    ? Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.69,
                                      mainAxisSpacing: 20.0,
                                      crossAxisSpacing: 15.0),
                              itemCount: pizza.length,
                              itemBuilder: (context, index) {
                                return FoodTile(pizza[index].name!,
                                    pizza[index].image!, pizza[index].price!);
                              }),
                        ),
                      )
                    : track == "1"
                        ? Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 10.0),
                              child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.69,
                                          mainAxisSpacing: 20.0,
                                          crossAxisSpacing: 15.0),
                                  itemCount: burger.length,
                                  itemBuilder: (context, index) {
                                    return FoodTile(
                                        burger[index].name!,
                                        burger[index].image!,
                                        burger[index].price!);
                                  }),
                            ),
                          )
                        : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(
                    image: data["Image"],
                    name: data["Name"],
                    price: data["Price"])));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.only(left: 20.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 100,
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      data["Image"],
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  width: 20.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      "\$" + data["Price"],
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: 20.0),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Color(0xffef2b39),
                      borderRadius: BorderRadius.circular(60)),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget FoodTile(String name, String image, String price) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, top: 10.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              image,
              height: 60,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            name,
            style: AppWidget.boldTextFeildStyle(),
          ),
          Text(
            "\$" + price,
            style: AppWidget.priceTextFeildStyle(),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailPage(
                                image: image,
                                name: name,
                                price: price,
                              )));
                },
                child: Container(
                  height: 50,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Color(0xffef2b39),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomRight: Radius.circular(20))),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget CategoryTile(String name, String image, String categoryindex) {
    return GestureDetector(
      onTap: () {
        track = categoryindex.toString();

        setState(() {});
      },
      child: track == categoryindex
          ? Container(
              margin: EdgeInsets.only(right: 20.0, bottom: 10.0),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  decoration: BoxDecoration(
                      color: Color(0xffef2b39),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: [
                      Image.asset(
                        image,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        name,
                        style: AppWidget.whiteTextFeildStyle(),
                      )
                    ],
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              margin: EdgeInsets.only(right: 20.0, bottom: 10.0),
              decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Image.asset(
                    image,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    name,
                    style: AppWidget.SimpleTextFeildStyle(),
                  )
                ],
              ),
            ),
    );
  }
}
