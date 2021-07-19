/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-07-18 17:10:54
 */

import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/service/service_register.dart' as msr;
import 'package:xy_music_mobile/config/theme_data.dart' as tdr;
import 'package:xy_music_mobile/config/database_config.dart' as database;

class Application {
  //Router全局路由管理对象
  static late FluroRouter router;

  //消息总线
  static final EventBus eventBus = EventBus();

  // static late BuildContext context;

  ///IOS 可侧滑返回的跳转界面
  static Future navigateToIos(BuildContext context, String path,
      {bool replace = false, bool clearStack = false, Object? params}) {
    RouteSettings? settings;
    if (params != null) {
      settings = RouteSettings(name: "params", arguments: params);
    }
    return router.navigateTo(context, path,
        replace: replace,
        clearStack: clearStack,
        transition: TransitionType.cupertino,
        routeSettings: settings);
  }

  ///原生跳转
  static Future navigateToNative(BuildContext context, String path,
      {bool replace = false, bool clearStack = false, Object? params}) {
    RouteSettings? settings;
    if (params != null) {
      settings = RouteSettings(name: "params", arguments: params);
    }
    return router.navigateTo(context, path,
        replace: replace,
        clearStack: clearStack,
        transition: TransitionType.native,
        routeSettings: settings);
  }

  ///初始化
  static void applicationInit() {
    //音乐服务注册
    msr.register();

    //主题服务数据注入
    tdr.register();

    ///初始化DataBase
    database.initDataBase();
  }
}
