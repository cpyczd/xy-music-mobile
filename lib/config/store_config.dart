/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:47:34
 * @LastEditTime: 2021-07-15 21:47:52
 */

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:xy_music_mobile/model/hive_store_model.dart';
import 'package:xy_music_mobile/model/play_list_model.dart';

class Store {
  ///Hive存储的Box名称
  static const HIVE_BOX_NAME = "xy-music-nosql-box";

  ///默认盒子
  static late final Box<Map> defaultBox;

  ///初始化
  static Future<void> flutterInit({bool initBox = true}) async {
    //初始化Hive
    var directory = await pathProvider.getApplicationSupportDirectory();
    Hive.init(directory.path);
    _registerAdapter();
    if (initBox) {
      defaultBox = await Hive.openBox<Map>(Store.HIVE_BOX_NAME);
    }
  }

  ///注册适配器
  static void _registerAdapter() {
    Hive.registerAdapter(HiveStoreModelAdapter(), override: true);
    Hive.registerAdapter(PlayListModelAdapter(), override: true);
  }

  ///打开一个盒子
  static Future<Box<T>> openBox<T>(String key) {
    if (Hive.isBoxOpen(key)) {
      return Future.value(Hive.box<T>(key));
    }
    return Hive.openBox<T>(key);
  }

  ///懒加载打开一个盒子
  static Future<LazyBox<T>> openBoxLaye<T>(String key) {
    if (Hive.isBoxOpen(key)) {
      return Future.value(Hive.lazyBox<T>(key));
    }
    return Hive.openLazyBox<T>(key);
  }

  ///关闭一个盒子
  static void closeBox(String key) {
    if (Hive.isBoxOpen(key)) {
      Hive.box(key).close();
    }
  }
}
