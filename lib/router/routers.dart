/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-06-20 18:25:04
 */
import 'package:fluro/fluro.dart';
import 'router_handler.dart';

///路由的配置
class Routers {
  static void configRouters(FluroRouter router) {
    _defineRouter(router, "/", homePage);
    _defineRouter(router, "/player", playerPage);
    _defineRouter(router, "/search", searchPage);
    _defineRouter(router, "/squareInfoPage", squareInfoPage);
    _defineRouter(router, "/squareListPage", squareListPage);
    _defineRouter(router, "/squareTagSelected", squareTagSelectedPage);
    // _defineRouter(router, "/detail/:index", chatDetailHandler);
  }

  static void _defineRouter(FluroRouter router, String path, Handler handler) {
    router.define(path,
        handler: handler, transitionType: TransitionType.inFromRight);
  }
}
