/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-09 16:13:33
 * @LastEditTime: 2021-07-09 17:44:10
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
    // TODO: implement formatLyric
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getHotSearch() {
    // TODO: implement getHotSearch
    throw UnimplementedError();
  }

  @override
  Future<String> getLyric(MusicEntity entity) {
    // TODO: implement getLyric
    throw UnimplementedError();
  }

  @override
  List<BaseParseMusicPlayUrl> getParseRouters() {
    // TODO: implement getParseRouters
    throw UnimplementedError();
  }

  @override
  Future<String> getPic(MusicEntity entity) {
    // TODO: implement getPic
    throw UnimplementedError();
  }

  @override
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0}) async {
    Map resp = await HttpUtil.get("http://search.kuwo.cn/r.s", data: {
      "client": "kt",
      "all": keyword,
      "pn": current,
      "rn": size,
      "uid": "794762570",
      "ver": "kwplayer_ar_9.2.2.1",
      "vipver": "1",
      "show_copyright_off": "1",
      "newver": "1",
      "ft": "music",
      "cluster": "0",
      "strategy": "2012",
      "encoding": "utf-8",
      "rformat": "json",
      "vermerge": "1",
      "mobi": "1",
      "issubtitle": "1",
    });
    if (resp["TOTAL"] != '0' && resp["SHOW"] == '0') {
      return Future.error("搜索失败");
    }
    return (resp["abslist"] as List)
        .where((element) => StringUtils.isNotBlank(element["MINFO"]))
        .map((e) {
      var songId = (e["MUSICRID"] as String).replaceAll('MUSIC_', '');
      return MusicEntity(
          songmId: songId,
          songName: e["SONGNAME"],
          source: MusicSourceConstant.kw,
          duration: Duration(seconds: e["DURATION"]),
          originData: e);
    }).toList();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    // TODO: implement setQuality
    throw UnimplementedError();
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    // TODO: implement supportSource
    throw UnimplementedError();
  }
}
