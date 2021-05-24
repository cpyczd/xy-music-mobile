/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:47:34
 * @LastEditTime: 2021-05-22 15:47:35
 */

import 'package:hive/hive.dart';

class Store {
  ///Hive存储的Box名称
  static const HIVE_BOX_NAME = "xy-music-nosql-box";

  static late final Box<Map> hiveBox;
}
