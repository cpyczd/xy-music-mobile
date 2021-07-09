/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-09 16:13:33
 * @LastEditTime: 2021-07-09 23:56:51
 */

import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/lyric.dart';

import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/util/http_util.dart';
import 'package:xy_music_mobile/util/index.dart';
import '../base_music_service.dart';

///酷我音乐解析服务
class KwMusicServiceImpl extends BaseMusicService {
  @override
  List<Lyric> formatLyric(String lyricStr) {
    return defaultFormatLyric(lyricStr);
  }

  @override
  Future<List<String>> getHotSearch() {
    throw UnimplementedError();
  }

  @override
  Future<String> getLyric(MusicEntity entity) async {
    Map resp = await HttpUtil.get(
        "https://m.kuwo.cn/newh5/singles/songinfoandlrc?musicId=${entity.songmId}&httpsStatus=1");
    if (resp["status"] != 200) {
      return Future.error("获取歌词失败");
    }
    StringBuffer sb = StringBuffer();
    (resp["data"]["lrclist"] as List).forEach((e) {
      double time = num.parse(e["time"]).toDouble();
      var duration = Duration(
          seconds: time.floor(), milliseconds: (time - time.floor()).toInt());
      sb.write("[");
      sb.write(DateUtil.formatDate(
          DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds),
          format: "mm:ss.SSS"));
      sb.write("]");
      sb.write(e["lineLyric"]);
      sb.write("\n");
    });
    return sb.toString();
  }

  @override
  List<BaseParseMusicPlayUrl> getParseRouters() {
    return [_BetaMusicParse()];
  }

  @override
  Future<String> getPic(MusicEntity entity) async {
    var url =
        "http://artistpicserver.kuwo.cn/pic.web?corp=kuwo&type=rid_pic&pictype=500&size=500&rid=${entity.songmId}";
    String body = await HttpUtil.get(url, serializationJson: false);
    if (body.isNotEmpty) {
      entity.picImage = body;
      return body;
    }
    return Future.error("获取图片失败");
  }

  @override
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0}) async {
    Map resp = await HttpUtil.get(
        "http://search.kuwo.cn/r.s?client=kt&all=$keyword&pn=$current&rn=$size&uid=794762570&ver=kwplayer_ar_9.2.2.1&vipver=1&show_copyright_off=1&newver=1&ft=music&cluster=0&strategy=2012&encoding=utf8&rformat=json&vermerge=1&mobi=1&issubtitle=1");
    if (resp["TOTAL"] == '0' && resp["SHOW"] == '0') {
      return Future.error("搜索失败");
    }
    return (resp["abslist"] as List)
        .where((element) => StringUtils.isNotBlank(element["MINFO"]))
        .map((e) {
      var songId = (e["MUSICRID"] as String).replaceAll('MUSIC_', '');
      return MusicEntity(
          songmId: songId,
          albumId: e["ALBUMID"],
          albumName: e["ALBUM"],
          singer: (e["ARTIST"] as String).replaceAll("&", "、"),
          songName: e["SONGNAME"],
          source: MusicSourceConstant.kw,
          duration: Duration(seconds: int.parse(e["DURATION"] ?? 0)),
          durationStr: getTimeStamp(
              Duration(seconds: int.parse(e["DURATION"] ?? 0)).inMilliseconds),
          originData: e);
    }).toList();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    throw UnimplementedError();
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.kw;
  }
}

///稳定的音乐播放
class _BetaMusicParse extends BaseParseMusicPlayUrl {
  @override
  PlayUrlParseRoutesEnum getParseRoute() {
    return PlayUrlParseRoutesEnum.BETA;
  }

  @override
  Future<String> parsePlayUrl(MusicEntity entity) async {
    Map resp = await HttpUtil.get(
        "http://www.kuwo.cn/url?rid=MUSIC_${entity.songmId}&type=convert_url3&br=128kmp3");
    if (resp["code"] != 200) {
      return Future.error("获取播放地址失败");
    }
    String? url = resp["url"];
    if (url == null || url.isEmpty) {
      return Future.error("获取播放地址失败");
    }
    entity.playUrl = url;
    return url;
  }
}
