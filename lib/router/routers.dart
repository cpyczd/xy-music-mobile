/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-05-22 15:13:10
 */
import 'package:fluro/fluro.dart';
import ' router_handler.dart';

///路由的配置
class Routers {
  static void configRouters(FluroRouter router) {
    _defineRouter(router, "/", homePage);
    // _defineRouter(router, "/register", registerHandler);
    // _defineRouter(router, "/", startHandler);
    // _defineRouter(router, "/renewal", renewalHandler);
    // _defineRouter(router, "/index", indexHandler);
    // _defineRouter(router, "/detail/:index", chatDetailHandler);
  }

  static void _defineRouter(FluroRouter router, String path, Handler handler) {
    router.define(path,
        handler: handler, transitionType: TransitionType.inFromRight);
  }
}
