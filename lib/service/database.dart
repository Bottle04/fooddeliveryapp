// file: database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // HÀM MỚI: Lấy chi tiết người dùng theo ID (Cần cho Login và Profile)
  Future<DocumentSnapshot> getUserDetails(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).get();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> CODE MỚI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  // HÀM THÊM SẢN PHẨM MỚI (CREATE) - DÙNG TRONG add_food.dart
  Future addFoodItem(Map<String, dynamic> foodInfoMap, String category) async {
    return await FirebaseFirestore.instance
        .collection(category)
        .doc()
        .set(foodInfoMap);
  }

  // HÀM LẤY SẢN PHẨM THEO CATEGORY (READ) - DÙNG TRONG home.dart
  Future<Stream<QuerySnapshot>> getFoodItems(String category) async {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  // HÀM XÓA SẢN PHẨM (DELETE) - DÙNG TRONG edit_food_list.dart [MỚI]
  Future deleteFoodItem(String category, String docId) async {
    return await FirebaseFirestore.instance
        .collection(category)
        .doc(docId)
        .delete();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> END MỚI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  Future addUserOrderDetails(
      Map<String, dynamic> userOrderMap, String id, String orderid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .doc(orderid)
        .set(userOrderMap);
  }

  Future addAdminOrderDetails(
      Map<String, dynamic> userOrderMap, String orderid) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(orderid)
        .set(userOrderMap);
  }

  Future<Stream<QuerySnapshot>> getUserOrders(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .snapshots();
  }

  Future<QuerySnapshot> getUserWalletbyemail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
  }

  Future updateUserWallet(String amount, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  Future<Stream<QuerySnapshot>> getAdminOrders() async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  Future updateAdminOrder(String id) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(id)
        .update({"Status": "Delivered"});
  }

  Future updateUserOrder(String userid, String docid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("Orders")
        .doc(docid)
        .update({"Status": "Delivered"});
  }

  Future<Stream<QuerySnapshot>> getAllUsers() async {
    return await FirebaseFirestore.instance.collection("users").snapshots();
  }

  Future deleteUser(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .delete();
  }

  Future addUserTransaction(
      Map<String, dynamic> userOrderMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transaction")
        .add(userOrderMap);
  }

  Future<Stream<QuerySnapshot>> getUserTransactions(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transaction")
        .snapshots();
  }

  Future<QuerySnapshot> search(String updatedname) async {
    return await FirebaseFirestore.instance
        .collection("Food")
        .where("SearchKey",
            isEqualTo: updatedname.substring(0, 1).toUpperCase())
        .get();
  }
}
