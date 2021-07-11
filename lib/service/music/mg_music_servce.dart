/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-06 17:25:09
 * @LastEditTime: 2021-07-11 13:24:16
 */

import 'package:dio/dio.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import '/util/index.dart' as util;

///咪咕音乐正式版
class MgMusicServiceImpl extends BaseMusicService {
  @override
  Future<String> getLyric(MusicEntity entity) async {
    if (entity.lrc == null) {
      Map resp = await util.HttpUtil.get(
          "https://api.gmit.vip/Api/MiGu?format=json&id=${entity.songmId}");
      if (resp["code"] != 200) {
        return Future.error("请求歌词失败");
      }
      String? lrc = resp["data"]["lrc"];
      if (lrc == null || lrc.isEmpty) {
        return Future.error("请求歌词失败");
      }
      entity.lrc = lrc;
      //解析最后一行时间
      var timeStr =
          lrc.substring(lrc.lastIndexOf("[") + 1, lrc.lastIndexOf("]"));
      //分
      var minute = timeStr.substring(0, timeStr.indexOf(":"));
      //秒
      var second = timeStr.split(":")[1].split(".")[0];
      //毫秒
      var millSecond = timeStr.split(":")[1].split(".")[1];
      var duration = Duration(
          minutes: int.parse(minute),
          seconds: int.parse(second),
          milliseconds: int.parse(millSecond));
      entity.duration = duration;
      entity.durationStr = util.getTimeStamp(duration.inMilliseconds);
      return lrc;
    }
    return entity.lrc!;
  }

  @override
  Future<String> getPic(MusicEntity entity) {
    return Future.value(entity.picImage);
  }

  @override
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0}) async {
    Map resp = await util.HttpUtil.get(
        "http://pd.musicapp.migu.cn/MIGUM2.0/v1.0/content/search_all.do",
        data: {
          "ua": "Android_migu",
          "version": "5.0.1",
          "text": keyword,
          "searchSwitch":
              '{"song":1,"album":0,"singer":0,"tagSong":0,"mvSong":0,"songlist":0,"bestShow":1}',
          "pageNo": current + 1
        },
        options: Options(headers: {
          "referer": "http://music.migu.cn/",
          "User-Agent":
              "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1"
        }));
    if (resp["code"] != "000000") {
      return Future.error("请求失败");
    }
    return (resp["songResultData"]["result"] as List).map((e) {
      String play = e["rateFormats"][0]["url"] as String;
      play = play.substring(play.indexOf("/public"));
      return MusicEntity(
          songmId: e["copyrightId"],
          singer: (e["singers"] as List).map((e) => e["name"]).join("、"),
          picImage:
              (e["imgItems"] != null && (e["imgItems"] as List).isNotEmpty)
                  ? e["imgItems"][0]["img"]
                  : null,
          playUrl: "https://freetyst.nf.migu.cn/$play",
          songName: e["name"],
          source: MusicSourceConstant.mg,
          duration: Duration.zero,
          durationStr: "-",
          originData: e);
    }).toList();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    return entity;
  }

  @override
  Future<List<String>> getHotSearch() {
    throw UnimplementedError();
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.mg;
  }

  @override
  List<Lyric> formatLyric(String lyricStr) {
    return defaultFormatLyric(lyricStr);
  }

  @override
  List<BaseParseMusicPlayUrl> getParseRouters() {
    return [_AlphaMusicParse(this)];
  }
}

class _AlphaMusicParse extends BaseParseMusicPlayUrl {
  MgMusicServiceImpl serviceImpl;

  _AlphaMusicParse(this.serviceImpl);

  @override
  PlayUrlParseRoutesEnum getParseRoute() {
    return PlayUrlParseRoutesEnum.BETA;
  }

  @override
  Future<String> parsePlayUrl(MusicEntity entity) async {
    await serviceImpl.getLyric(entity);
    return entity.playUrl!;
  }
}
