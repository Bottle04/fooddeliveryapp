import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userImagekey = "USERIMAGEKEY";
  static String userAddresskey = "USERADDRESSKEY";

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserAddress(String getUserAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userAddresskey, getUserAddress);
  }

  Future<bool> saveUserImage(String getUserImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userImagekey, getUserImage);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userAddresskey);
  }

  Future<String?> getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userImagekey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  // ✅ HÀM MỚI: XÓA ĐỊA CHỈ NGƯỜI DÙNG
  Future<bool> removeUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(userAddresskey);
  }

  // Bạn nên có hàm xóa toàn bộ dữ liệu người dùng khi logout để đảm bảo không bị lỗi dữ liệu chéo
  Future<bool> clearAllUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
    await prefs.remove(userNameKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userImagekey);
    await prefs.remove(userAddresskey);
    return true;
  }
}
