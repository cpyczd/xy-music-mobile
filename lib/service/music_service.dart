/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 18:29:30
 * @LastEditTime: 2021-05-24 21:23:18
 */
import 'package:dio/dio.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/util/http_util.dart';

abstract class MusicService {
  static CancelToken? _cancelToken;

  ///搜索
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0});

  ///获取歌词
  Future<String> getLyric(MusicEntity entity);

  ///获取图片
  Future<String> getPic(MusicEntity entity);

  ///获取排行榜
  //Future<List<MusicEntity>> getHotRankings(Map<String, dynamic> params);

  ///获取歌单
  //Future<List<Map<String, dynamic>>> getMusicSquare(Map<String, dynamic> params);

  ///获取歌单详情
  Future<List<Map<String, dynamic>>> getMusicSquareDetail(
      Map<String, dynamic> params);

  ///获取热搜词
  //List<String> getHotSearch(Map<String, dynamic> params);

  ///获取评论
  //List<Map<String, dynamic>> getComment(Map<String, dynamic> params);

  ///获取音乐详情
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity);

  MusicEntity setQuality(MusicEntity entity, Map map);

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
