import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPrefrences;
  static Future init() async {
    sharedPrefrences = await SharedPreferences.getInstance();
  }

  static Future<bool?> saveData(
      {required String key, required dynamic value}) async {
    if (value is int) {
      return await sharedPrefrences.setInt(key, value);
    } else if (value is String) {
      return await sharedPrefrences.setString(key, value);
    } else if (value is bool) {
      return await sharedPrefrences.setBool(key, value);
    }
    return await sharedPrefrences.setDouble(key, value);
  }

  static Future<dynamic> getData({required String key}) async {
    return sharedPrefrences.get(key);
  }

  static Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPrefrences.remove(key);
  }
}
