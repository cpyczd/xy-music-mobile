import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'application.dart';
import 'router/routers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //配置路由的相关配置
    FluroRouter router = new FluroRouter();
    Routers.configRouters(router);
    Application.router = router;
    Application.context = context;
    // HttpUtil.debug(true);

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
