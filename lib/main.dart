/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-07-02 16:01:00
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'config/store_config.dart' as store;

import 'application.dart';
import 'router/routers.dart';
import 'util/http_util.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //初始化相关配置
    Application.applicationInit();
    FluroRouter router = new FluroRouter();
    Routers.configRouters(router);
    Application.router = router;
    Application.context = context;
    // HttpUtil.logOpen();
    // HttpUtil.openProxy();
    // log.close();
    // store.Store.flutterInit();

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
      theme: AppTheme.getThemeData(),
      // theme: ThemeData(
      //   backgroundColor: Color.fromRGBO(248, 248, 248, 1),
      //   primarySwatch: Colors.lightBlue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
    );
  }
}
