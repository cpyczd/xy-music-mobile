/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-13 22:37:08
 * @LastEditTime: 2021-06-13 22:37:59
 */
import 'package:xy_music_mobile/util/http_util.dart';
import 'package:dio/dio.dart';

class SearchHelper {
  static CancelToken? _cancelToken;

  ///搜索建议获取 Token
  static Future<String> getToken() async {
    var response = await HttpUtil.getBaseHttp().get("http://www.kuwo.cn/");
    var cookie = response.headers.value('set-cookie') as String;
    print("Cookie: $cookie");
    return cookie.split(";")[0].replaceAll("kw_token=", "").trim();
  }

  ///搜索建议
  static Future<List<String>> getSearchTip(
      String keyWord, String? token) async {
    if (token == null || token.isEmpty) {
      token = await getToken();
    }
    _cancelToken?.cancel(null);
    _cancelToken = CancelToken();

    Map result = await HttpUtil.get(
        "http://www.kuwo.cn/api/www/search/searchKey",
        data: {"key": keyWord},
        options: Options(headers: {
          "Referer": "http://www.kuwo.cn/",
          "csrf": token,
          "Cookie": "kw_token=$token"
        }),
        cancelToken: _cancelToken);
    if (result["code"] != 200) {
      return Future.error("搜索失败");
    }
    return (result['data'] as List).map((e) {
      String str = e.toString();
      return str.substring(str.indexOf("=") + 1, str.indexOf("\r"));
    }).toList();
  }
}
