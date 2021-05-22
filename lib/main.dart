/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-05-22 16:11:37
 */
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'config/store_config.dart' as store;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_logger/simple_logger.dart';

import 'application.dart';
import 'router/routers.dart';
import 'util/http_util.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'config/logger_config.dart' as log;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //初始化相关配置
    FluroRouter router = new FluroRouter();
    Routers.configRouters(router);
    Application.router = router;
    Application.context = context;
    HttpUtil.level(Level.INFO);
    log.setLoggerLavel(Level.ALL);
    SharedPreferences.getInstance();
    //初始化Hive
    pathProvider
        .getApplicationDocumentsDirectory()
        .then((Directory directory) async {
      Hive.init(directory.path);
      store.Store.hiveBox = await Hive.openBox<Map>(store.Store.hive_box_box);
    });

    return MaterialApp(
      title: 'Xy-Music',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Application.router.generator,
      initialRoute: "/",
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
