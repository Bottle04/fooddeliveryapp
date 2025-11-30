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
  // 1. Khai báo các Stream để chứa dữ liệu từ Firestore
  Stream<QuerySnapshot>? pizzaStream;
  Stream<QuerySnapshot>? burgerStream;
  Stream<QuerySnapshot>? chineseStream;
  Stream<QuerySnapshot>? mexicanStream;

  List<CategoryModel> categories = [];
  String track = "0";
  bool search = false;
  TextEditingController searchcontroller = new TextEditingController();

  // 2. Hàm lấy dữ liệu khi màn hình tải
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

  // Logic tìm kiếm
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

  // 3. Widget hiển thị danh sách sản phẩm (Dùng StreamBuilder)
  Widget allItems(Stream<QuerySnapshot>? stream) {
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
            shrinkWrap: true, // Cần thiết khi đặt trong SingleChildScrollView
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.69, // Tỷ lệ khung hình thẻ
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 15.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];

              String name = ds["Name"] ?? "No Name";
              String image = ds["Image"] ?? "";
              String price = ds["Price"] ?? "0";
              String desc =
                  ds["Description"] ?? "No Description"; // Lấy Description

              return FoodTile(name, image, price, desc); // Truyền desc
            });
      },
    );
  }

  // 4. Hàm chọn Stream dựa trên Category đang chọn
  Widget getSelectedFoodList() {
    switch (track) {
      case "0":
        return allItems(pizzaStream);
      case "1":
        return allItems(burgerStream);
      case "2":
        return allItems(chineseStream);
      case "3":
        return allItems(mexicanStream);
      default:
        return allItems(pizzaStream);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bọc toàn bộ Body bằng SingleChildScrollView để fix tràn dọc
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

              // 5. Phần Body Chính (GridView)
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: getSelectedFoodList(),
              ),

              SizedBox(height: 30.0), // Khoảng cách an toàn cuối cùng
            ],
          ),
        ),
      ),
    );
  }

  // Widget thẻ kết quả tìm kiếm (Giữ nguyên)
  Widget buildResultCard(data) {
    /* ... */ return Container();
  }

  // 6. Cập nhật FoodTile (Truyền đầy đủ các thông tin cần thiết & Fix lỗi ảnh)
  Widget FoodTile(String name, String image, String price, String desc) {
    // Hàm đẩy lên DetailPage
    void navigateToDetailPage() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPage(
                  image: image, name: name, price: price, description: desc)));
    }

    // LOGIC XỬ LÝ HIỂN THỊ ẢNH MỚI: Kiểm tra URL trước
    Widget foodImageWidget;

    // Nếu URL hợp lệ (không rỗng và bắt đầu bằng http/https), sử dụng Image.network
    if (image.isNotEmpty &&
        (image.startsWith('http') || image.startsWith('https'))) {
      foodImageWidget = Image.network(
        image,
        height: 100,
        width: 150,
        fit: BoxFit.cover,
        // Vẫn giữ errorBuilder để đề phòng lỗi mạng bất ngờ
        errorBuilder: (context, error, stackTrace) {
          return Image.asset("images/pan.png",
              height: 100, width: 150, fit: BoxFit.cover);
        },
      );
    } else {
      // Trường hợp URL rỗng hoặc không hợp lệ, sử dụng Image.asset
      foodImageWidget = Image.asset("images/pan.png",
          height: 100, width: 150, fit: BoxFit.cover);
    }
    // ----------------------------

    return GestureDetector(
      onTap: navigateToDetailPage, // Dùng hàm navigate
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh (Đã sửa)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: foodImageWidget, // <<< SỬ DỤNG WIDGET ẢNH ĐÃ XỬ LÝ
                ),
              ),
            ),
            SizedBox(height: 5.0),
            // Tên
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                style: AppWidget.boldTextFeildStyle(),
                maxLines: 1, // Giới hạn dòng
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5.0),
            // Mô tả/Sub-text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Fresh & Healthy",
                style: AppWidget.SimpleTextFeildStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5.0),
            // Giá và Nút
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$" + price,
                    style: AppWidget.priceTextFeildStyle(),
                  ),
                  GestureDetector(
                    onTap: navigateToDetailPage, // Dùng hàm navigate
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.arrow_forward,
                          color: Colors.white, size: 20),
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
                      Image.asset(
                        image,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10.0),
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
                  SizedBox(width: 10.0),
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
