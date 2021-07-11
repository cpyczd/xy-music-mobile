/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2020-08-05 14:00:34
 * @LastEditTime: 2021-07-11 17:54:46
 */
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import '/util/widget_common.dart';

class HttpUtil {
  static var _log = Logger(level: Level.nothing);

  static CancelToken _cancelToken = CancelToken();

  ///控制debug开关
  static void logOpen() {
    _log = Logger();
  }

  ///设置代理
  static void openProxy() {
    (_http.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (url) {
        ///设置代理 电脑ip地址
        return "PROXY 127.0.0.1:8888";

        ///不设置代理
//          return 'DIRECT';
      };

      ///忽略证书
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
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
        _log.i(
            "HttpDebug =====> Request: ${response.requestOptions.path} ${response.requestOptions.method}");
        _log.i(
            "HttpDebug =====> --->RequestData: Data:${response.requestOptions.data} Params:${response.requestOptions.queryParameters}");
        _log.i(
            "HttpDebug =====> --->Response: ${response.statusMessage}-${response.statusCode}  ${response.data}");
        _log.i("HttpDebug =====> END");
        handler.next(response);
      },
      onError: (DioError e, ErrorInterceptorHandler handler) async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          //网络断开连接
          ToastUtil.show(msg: "失败: 无网络连接", length: Toast.LENGTH_LONG);
        }
        _log.e("DioError请求错误Resp内容: ${e.response?.data}");
        handler.reject(e);
      },
    ));

  ///进行Get请求的操作
  static Future<T> get<T>(String url,
      {data,
      options,
      CancelToken? cancelToken,
      bool serializationJson = true}) async {
    try {
      var response = await _http.get(url,
          queryParameters: data,
          cancelToken: cancelToken == null ? _cancelToken : cancelToken,
          options: options);
      return response.data is Map
          ? response.data as T
          : serializationJson
              ? json.decode(response.data) as T
              : response.data as T;
    } catch (e) {
      _log.e("请求异常：$e");
      return Future.error("系统请求异常");
    }
  }

  ///进行Post的请求
  static Future<T> post<T>(String url,
      {Map<String, dynamic>? data,
      bool urlParams = false,
      options,
      CancelToken? cancelToken,
      bool serializationJson = true}) async {
    try {
      var response = await _http.post(url,
          data: !urlParams ? data : null,
          cancelToken: cancelToken == null ? _cancelToken : cancelToken,
          queryParameters: urlParams ? data : null,
          options: options);
      return response.data is Map
          ? response.data as T
          : serializationJson
              ? json.decode(response.data) as T
              : response.data as T;
    } catch (e) {
      _log.e("请求异常：$e}");
      return Future.error("系统请求异常");
    }
  }

  static Dio getBaseHttp() {
    return _http;
  }
}
