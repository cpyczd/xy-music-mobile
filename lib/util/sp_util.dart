/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-16 10:10:02
 * @LastEditTime: 2021-06-16 10:17:35
 */

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SpUtil {
  ///获取实例对象
  static Future<SharedPreferences> getInstance() {
    return SharedPreferences.getInstance();
  }

  ///保存
  static Future<bool> save(String key, Map<String, dynamic> map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, json.encode(map));
  }

  ///获取值
  static Future<Map> getVal(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(key);
    if (val == null) {
      return Future.error("Null");
    }
    return json.decode(val);
  }
}
