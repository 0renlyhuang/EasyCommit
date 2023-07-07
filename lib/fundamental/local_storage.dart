import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? store;
  static Future init() async {
    store = await SharedPreferences.getInstance();
  }
}