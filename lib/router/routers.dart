import 'package:fluro/fluro.dart';

class Routers {
  static void configRouters(FluroRouter router) {
    // _defineRouter(router, "/login", loginHandler);
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
