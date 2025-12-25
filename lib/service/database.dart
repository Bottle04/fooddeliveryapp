// file: database.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // === USER MANAGEMENT ===

  // CREATE: Thêm chi tiết người dùng mới
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // READ: Lấy chi tiết người dùng theo ID
  Future<DocumentSnapshot> getUserDetails(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).get();
  }

  // READ: Lấy tất cả người dùng (Admin)
  Future<Stream<QuerySnapshot>> getAllUsers() async {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  // DELETE: Xóa người dùng
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

  // READ: Lấy danh sách sản phẩm theo Category
  Future<Stream<QuerySnapshot>> getFoodItems(String category) async {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  // UPDATE: Cập nhật chi tiết món ăn
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

  // READ: Tìm kiếm món ăn
  Future<QuerySnapshot> search(String updatedname) async {
    // Lưu ý: Để tìm kiếm hiệu quả, bạn nên có một collection "Food" chứa tất cả món ăn
    // hoặc tìm kiếm trong từng category riêng biệt.
    return await FirebaseFirestore.instance
        .collection("Food")
        .where("SearchKey",
            isEqualTo: updatedname.substring(0, 1).toUpperCase())
        .get();
  }

  // === RATING MANAGEMENT (MỚI THÊM) ===

  // Hàm tính toán và cập nhật điểm đánh giá
  Future addFoodRating(String category, String foodId, double rating) async {
    DocumentReference foodRef =
        FirebaseFirestore.instance.collection(category).doc(foodId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(foodRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      // Lấy dữ liệu cũ (nếu chưa có thì mặc định là 0)
      double currentTotalRating = (data["TotalRating"] ?? 0.0).toDouble();
      int currentRatingCount = (data["RatingCount"] ?? 0).toInt();

      // Tính toán số liệu mới
      int newCount = currentRatingCount + 1;
      double newTotal = currentTotalRating + rating;
      double averageRating = newTotal / newCount;

      // Cập nhật lại vào Firestore
      transaction.update(foodRef, {
        "TotalRating": newTotal,
        "RatingCount": newCount,
        "AverageRating": averageRating,
      });
    });
  }

  // === ORDER MANAGEMENT ===

  // CREATE: Thêm đơn hàng User
  Future addUserOrderDetails(
      Map<String, dynamic> userOrderMap, String id, String orderid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .doc(orderid)
        .set(userOrderMap);
  }

  // READ: Lấy đơn hàng User
  Future<Stream<QuerySnapshot>> getUserOrders(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .snapshots();
  }

  // UPDATE: Cập nhật trạng thái đơn hàng User
  Future updateUserOrder(String userid, String docid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("Orders")
        .doc(docid)
        .update({"Status": "Delivered"});
  }

  // CREATE: Thêm đơn hàng Admin
  Future addAdminOrderDetails(
      Map<String, dynamic> userOrderMap, String orderid) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(orderid)
        .set(userOrderMap);
  }

  // READ: Lấy đơn hàng Admin
  Future<Stream<QuerySnapshot>> getAdminOrders() async {
    return FirebaseFirestore.instance
        .collection("Orders")
        .orderBy("OrderTime", descending: false)
        .snapshots();
  }

  // UPDATE: Cập nhật trạng thái đơn hàng Admin
  Future updateAdminOrder(String id) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(id)
        .update({"Status": "Delivered"});
  }

  // === WALLET MANAGEMENT ===

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

  Future addUserTransaction(
      Map<String, dynamic> userOrderMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transaction")
        .add(userOrderMap);
  }

  Future<Stream<QuerySnapshot>> getUserTransactions(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transaction")
        .snapshots();
  }
}
