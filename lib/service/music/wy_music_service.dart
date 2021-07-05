/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-26 20:19:46
 * @LastEditTime: 2021-07-04 18:15:12
 */
import 'package:dio/dio.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import 'package:xy_music_mobile/util/index.dart';
import '../square/wy_square_service.dart' show WyWebApi;
import 'package:xy_music_mobile/util/time.dart' show formatPlayTime;

class WyMusicServiceImpl extends BaseMusicService {
  late final WyWebApi webApi;

  WyMusicServiceImpl() {
    webApi = WyWebApi();
  }

  @override
  Future<String> getLyric(MusicEntity entity) async {
    Map resp = await HttpUtil.post("https://music.163.com/api/linux/forward",
        urlParams: true,
        options: Options(headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36'
        }),
        data: webApi.linuxapi({
          "method": 'POST',
          "url": 'https://music.163.com/api/song/lyric',
          "params": {
            "id": entity.songmId,
            "lv": -1,
            "kv": -1,
            "tv": -1,
          }
        }));
    if (resp["code"] != 200) {
      return Future.error("请求失败");
    }
    String lrc = resp["lrc"]["lyric"];
    entity.lrc = lrc;
    return lrc;
  }

  @override
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity) async {
    Map result = await HttpUtil.post("https://music.sonimei.cn/",
        data: {
          "input": entity.songmId,
          "type": "netease",
          "filter": "id",
          "page": 1
        },
        options: Options(headers: {
          "x-requested-with": "XMLHttpRequest",
          "Content-Type": "multipart/form-data"
        }));
    if (result["code"] != 200) {
      return Future.error("解析失败");
    }
    entity.playUrl = result["data"][0]["url"];
    return entity;
  }

  @override
  Future<String> getPic(MusicEntity entity) {
    return Future.value(entity.picImage);
  }

  @override
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0}) async {
    Map resp = await HttpUtil.post("https://music.163.com/weapi/search/get",
        options: Options(headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36',
          "origin": "https://music.163.com",
          "Content-Type": "application/x-www-form-urlencoded"
        }),
        // type: 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
        data: webApi.webapi({
          "s": keyword,
          "type": 1,
          "limit": size,
          "offset": current * size
        }));
    if (resp["code"] != 200) {
      return Future.error("请求失败");
    }
    if (resp["result"]["songs"] == null) {
      return List.empty();
    }
    List<String> songsId = (resp["result"]["songs"] as List)
        .map((e) => e["id"].toString())
        .toList();
    resp = await HttpUtil.post("https://music.163.com/weapi/v3/song/detail",
        options: Options(headers: {
          "User-Agent":
              "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36",
          "origin": "https://music.163.com"
        }),
        urlParams: true,
        data: webApi.webapi({
          "c": '[' + songsId.map((id) => ('{"id":' + id + '}')).join(',') + ']',
          "ids": '[' + songsId.join(',') + ']',
        }));
    if (resp["code"] != 200) {
      return Future.error("请求失败");
    }
    return (resp["songs"] as List)
        .map((e) => MusicEntity(
            songmId: e["id"].toString(),
            songName: e["name"],
            singer: (e["ar"] as List).map((e) => e["name"]).join("、"),
            albumName: e["al"]["name"],
            albumId: e["al"]["id"].toString(),
            originData: e,
            duration: Duration(milliseconds: e["dt"]),
            picImage: e["al"]["picUrl"],
            durationStr:
                getTimeStamp(Duration(milliseconds: e["dt"]).inMilliseconds),
            source: MusicSourceConstant.wy))
        .toList();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getHotSearch() {
    throw UnimplementedError();
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.wy;
  }
}
