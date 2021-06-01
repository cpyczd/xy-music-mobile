/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-06-01 17:55:31
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'config/store_config.dart' as store;

import 'application.dart';
import 'router/routers.dart';
import 'util/http_util.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void _init() async {
    //初始化Hive
    var directory = await pathProvider.getApplicationSupportDirectory();
    Hive.init(directory.path);
    store.Store.hiveBox = await Hive.openBox<Map>(store.Store.HIVE_BOX_NAME);
  }

  @override
  Widget build(BuildContext context) {
    //初始化相关配置
    FluroRouter router = new FluroRouter();
    Routers.configRouters(router);
    Application.router = router;
    Application.context = context;
    HttpUtil.logOpen();
    // log.close();
    _init();

    return MaterialApp(
      title: 'Xy-Music',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Application.router.generator,
      initialRoute: "/",
      builder: (context, child) => GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: child,
      ),
      theme: ThemeData(
        backgroundColor: Color.fromRGBO(248, 248, 248, 1),
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
