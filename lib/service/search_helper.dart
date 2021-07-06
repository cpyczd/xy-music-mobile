/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-13 22:37:08
 * @LastEditTime: 2021-07-06 22:56:45
 */
import 'package:xy_music_mobile/util/http_util.dart';
import 'package:dio/dio.dart';
import 'package:xy_music_mobile/util/sp_util.dart';

class SearchHelper {
  static CancelToken? _cancelToken;

  static final _tokenKey = "SearchHelper-token";

  ///搜索建议获取 Token
  static Future<String> getToken() async {
    Map? map = await SpUtil.getVal(_tokenKey);
    String token;
    if (map == null) {
      var response = await HttpUtil.getBaseHttp().get("http://www.kuwo.cn/");
      var cookie = response.headers.value('set-cookie') as String;
      token = cookie.split(";")[0].replaceAll("kw_token=", "").trim();
      await SpUtil.save(_tokenKey, {"token": token},
          exprie: 1, level: TimeExpireLevel.MINUTES);
    } else {
      token = map["token"];
    }
    return token;
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
