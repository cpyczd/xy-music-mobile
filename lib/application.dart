/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-06-01 21:11:22
 */

import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Application {
  //Router全局路由管理对象
  static late FluroRouter router;

  //消息总线
  static final EventBus eventBus = EventBus();

  static late BuildContext context;

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
}
