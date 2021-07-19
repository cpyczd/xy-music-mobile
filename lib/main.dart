/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-07-19 20:52:38
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/service/player/audio_service_task.dart';
import 'config/store_config.dart' as store;

import 'application.dart';
import 'router/routers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    Future.delayed(Duration.zero).then((value) {
      //初始化相关配置
      Application.applicationInit();
      FluroRouter router = new FluroRouter();
      Routers.configRouters(router);
      Application.router = router;
      // Application.context = context;
      PlayerTaskHelper.flutterInitListener();
      // HttpUtil.logOpen();
      // HttpUtil.openProxy();
      // log.close();
      store.Store.flutterInit();
      // Sqflite.devSetDebugModeOn(true);
    });
  }
  @override
  Widget build(BuildContext context) {
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
