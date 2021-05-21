import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Application {
  //Router全局路由管理对象
  static late FluroRouter router;

  //消息总线
  static final EventBus eventBus = EventBus();

  static late BuildContext context;
}
