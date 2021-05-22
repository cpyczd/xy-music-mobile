/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2020-08-05 14:00:34
 * @LastEditTime: 2021-05-22 16:13:39
 */
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/util/widget_common.dart';
import 'package:simple_logger/simple_logger.dart';
import '/config/logger_config.dart';

class HttpUtil {
  static final _log = SimpleLogger();

  static CancelToken _cancelToken = CancelToken();

  ///控制debug开关
  static void level(Level level) {
    _log.setLevel(level);
  }

  //清除等待的队列
  static void clearQueue() {
    _http.clear();
    _cancelToken.cancel(null);
    _cancelToken = CancelToken();
  }

  static final _http = new Dio(BaseOptions(
    connectTimeout: 10000,
    sendTimeout: 10000,
    receiveTimeout: 10000,
  ))
    ..interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        _log.info("debug:HttpResponse =============> ${response.data}");
        handler.next(response);
      },
      onError: (DioError e, ErrorInterceptorHandler handler) async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          //网络断开连接
          ToastUtil.show(msg: "失败: 无网络连接", length: Toast.LENGTH_LONG);
        }
        handler.next(e);
      },
    ));

  ///进行Get请求的操作
  static Future<T> get<T>(String url, {data}) async {
    try {
      var response = await _http.get(url,
          queryParameters: data, cancelToken: _cancelToken);
      return response.data as T;
    } catch (e) {
      _log.error("请求异常：$e");
      return Future.error("系统异常");
    }
  }

  ///进行Post的请求
  static Future<T> post<T>(String url,
      {Map<String, dynamic>? data, bool urlParams = false}) async {
    try {
      var response = await _http.post(url,
          data: !urlParams ? data : null,
          cancelToken: _cancelToken,
          queryParameters: urlParams ? data : null,
          options: Options(contentType: "application/x-www-form-urlencoded"));
      return response.data as T;
    } catch (e) {
      _log.error("请求异常：$e}");
      return Future.error("系统异常");
    }
  }

  ///发送JSON数据到服务器
  static Future<T> postBody<T>(String url, {data}) async {
    try {
      var response = await _http.post(url,
          data: data,
          cancelToken: _cancelToken,
          options: Options(contentType: "application/json"));
      return response.data as T;
    } catch (e) {
      _log.error("请求异常：$e}");
      return Future.error("系统异常");
    }
  }
}
