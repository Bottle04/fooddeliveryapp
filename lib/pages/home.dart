// file: home.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/model/category_model.dart';
import 'package:fooddeliveryapp/pages/detail_page.dart';
import 'package:fooddeliveryapp/service/category_data.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? pizzaStream;
  Stream<QuerySnapshot>? burgerStream;
  Stream<QuerySnapshot>? chineseStream;
  Stream<QuerySnapshot>? mexicanStream;

  List<CategoryModel> categories = [];
  String track = "0";
  bool search = false;
  TextEditingController searchcontroller = new TextEditingController();

  getOnTheLoad() async {
    pizzaStream = await DatabaseMethods().getFoodItems("Pizza");
    burgerStream = await DatabaseMethods().getFoodItems("Burger");
    chineseStream = await DatabaseMethods().getFoodItems("Chinese");
    mexicanStream = await DatabaseMethods().getFoodItems("Mexican");
    setState(() {});
  }

  @override
  void initState() {
    categories = getCategories();
    getOnTheLoad();
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

  // Sửa: Thêm tham số categoryName vào hàm allItems
  Widget allItems(Stream<QuerySnapshot>? stream, String categoryName) {
    if (stream == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No items available."));
        }

        return GridView.builder(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 15.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              Map<String, dynamic> data = ds.data() as Map<String, dynamic>;

              String name = data["Name"] ?? "No Name";
              String image = data["Image"] ?? "";
              String price = data["Price"] ?? "0";
              String desc = data["Description"] ?? "No Description";
              // Lấy ID món ăn
              String foodId = ds.id;

              double avgRating = data.containsKey("AverageRating")
                  ? (data["AverageRating"] as num).toDouble()
                  : 5.0;
              int ratingCount = data.containsKey("RatingCount")
                  ? (data["RatingCount"] as num).toInt()
                  : 0;

              // Truyền thêm foodId và categoryName vào FoodTile
              return FoodTile(name, image, price, desc, avgRating, ratingCount,
                  foodId, categoryName);
            });
      },
    );
  }

  Widget getSelectedFoodList() {
    // Sửa: Truyền tên Category chính xác vào allItems
    switch (track) {
      case "0":
        return allItems(pizzaStream, "Pizza");
      case "1":
        return allItems(burgerStream, "Burger");
      case "2":
        return allItems(chineseStream, "Chinese");
      case "3":
        return allItems(mexicanStream, "Mexican");
      default:
        return allItems(pizzaStream, "Pizza");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20.0, top: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/logo.png",
                          height: 50, width: 110, fit: BoxFit.contain),
                      Text("Order your favourite food!",
                          style: AppWidget.SimpleTextFeildStyle())
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("images/boy.jpg",
                          height: 60, width: 60, fit: BoxFit.cover),
                    ),
                  )
                ],
              ),
              SizedBox(height: 30.0),

              // Search Bar
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
                        onChanged: (value) =>
                            initiateSearch(value.toUpperCase()),
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
                              search = false;
                              setState(() {});
                            },
                            child: Icon(Icons.close,
                                color: Colors.white, size: 30.0),
                          )
                        : Icon(Icons.search, color: Colors.white, size: 30.0),
                  )
                ],
              ),
              SizedBox(height: 20.0),

              // Category List
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
              SizedBox(height: 20.0),

              // GridView
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: getSelectedFoodList(),
              ),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  // Sửa: Thêm tham số id và category vào FoodTile
  Widget FoodTile(String name, String image, String price, String desc,
      double avgRating, int ratingCount, String id, String category) {
    void navigateToDetailPage() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPage(
                  image: image,
                  name: name,
                  price: price,
                  description: desc,
                  // TRUYỀN ID VÀ CATEGORY SANG DETAIL PAGE
                  id: id,
                  category: category)));
    }

    Widget foodImageWidget;
    if (image.isNotEmpty &&
        (image.startsWith('http') || image.startsWith('https'))) {
      foodImageWidget = Image.network(image,
          height: 100,
          width: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
              "images/pan.png",
              height: 100,
              width: 150,
              fit: BoxFit.cover));
    } else {
      foodImageWidget = Image.asset("images/pan.png",
          height: 100, width: 150, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: navigateToDetailPage,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: foodImageWidget)),
            ),
            SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(name,
                  style: AppWidget.boldTextFeildStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4.0),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    "($ratingCount)",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              ),
            ),
            SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\$" + price, style: AppWidget.priceTextFeildStyle()),
                  GestureDetector(
                    onTap: navigateToDetailPage,
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          color: Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.arrow_forward,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      Image.asset(image,
                          height: 40, width: 40, fit: BoxFit.cover),
                      SizedBox(width: 10.0),
                      Text(name, style: AppWidget.whiteTextFeildStyle())
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
                  Image.asset(image, height: 40, width: 40, fit: BoxFit.cover),
                  SizedBox(width: 10.0),
                  Text(name, style: AppWidget.SimpleTextFeildStyle())
                ],
              ),
            ),
    );
  }
}
