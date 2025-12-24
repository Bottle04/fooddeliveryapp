// file: database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods {
  // === USER MANAGEMENT ===

  // CREATE: Thêm chi tiết người dùng mới
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // READ: Lấy chi tiết người dùng theo ID (Cần cho Login và Profile)
  Future<DocumentSnapshot> getUserDetails(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).get();
  }

  // READ: Lấy tất cả người dùng (Dùng cho Admin)
  Future<Stream<QuerySnapshot>> getAllUsers() async {
    return await FirebaseFirestore.instance.collection("users").snapshots();
  }

  // DELETE: Xóa người dùng theo ID
  Future deleteUser(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .delete();
  }

  // === FOOD/MENU MANAGEMENT ===

  // CREATE: Thêm sản phẩm mới
  Future addFoodItem(Map<String, dynamic> foodInfoMap, String category) async {
    return await FirebaseFirestore.instance
        .collection(category)
        .doc()
        .set(foodInfoMap);
  }

  // READ: Lấy danh sách sản phẩm theo Category (Dùng cho Home/Edit)
  Future<Stream<QuerySnapshot>> getFoodItems(String category) async {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  // UPDATE: Cập nhật chi tiết món ăn (Cần cho chức năng Chỉnh sửa)
  Future updateFoodItem(
      String category, String docId, Map<String, dynamic> updatedMap) async {
    return await FirebaseFirestore.instance
        .collection(category)
        .doc(docId)
        .update(updatedMap);
  }

  // DELETE: Xóa sản phẩm
  Future deleteFoodItem(String category, String docId) async {
    return await FirebaseFirestore.instance
        .collection(category)
        .doc(docId)
        .delete();
  }

  // READ: Tìm kiếm món ăn theo chữ cái đầu
  Future<QuerySnapshot> search(String updatedname) async {
    return await FirebaseFirestore.instance
        .collection("Food")
        .where("SearchKey",
            isEqualTo: updatedname.substring(0, 1).toUpperCase())
        .get();
  }

  // === ORDER MANAGEMENT ===

  // CREATE: Thêm đơn hàng vào collection của người dùng
  Future addUserOrderDetails(
      Map<String, dynamic> userOrderMap, String id, String orderid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .doc(orderid)
        .set(userOrderMap);
  }

  // READ: Lấy danh sách đơn hàng của người dùng
  Future<Stream<QuerySnapshot>> getUserOrders(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .snapshots();
  }

  // UPDATE: Cập nhật trạng thái đơn hàng của người dùng
  Future updateUserOrder(String userid, String docid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("Orders")
        .doc(docid)
        .update({"Status": "Delivered"});
  }

  // CREATE: Thêm đơn hàng vào collection chung cho Admin
  Future addAdminOrderDetails(
      Map<String, dynamic> userOrderMap, String orderid) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(orderid)
        .set(userOrderMap);
  }

  // READ: Lấy danh sách đơn hàng cho Admin (chỉ lấy đơn "Pending")
  Future<Stream<QuerySnapshot>> getAdminOrders() async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .orderBy("OrderTime", descending: false)
        .snapshots();
  }

  // UPDATE: Cập nhật trạng thái đơn hàng cho Admin
  Future updateAdminOrder(String id) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(id)
        .update({"Status": "Delivered"});
  }

  // === WALLET/TRANSACTION MANAGEMENT ===

  // READ: Lấy thông tin ví dựa trên email
  Future<QuerySnapshot> getUserWalletbyemail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
  }

  // UPDATE: Cập nhật số dư ví
  Future updateUserWallet(String amount, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  // CREATE: Thêm giao dịch mới
  Future addUserTransaction(
      Map<String, dynamic> userOrderMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transaction")
        .add(userOrderMap);
  }

  // READ: Lấy danh sách giao dịch của người dùng
  Future<Stream<QuerySnapshot>> getUserTransactions(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transaction")
        .snapshots();
  }
}
