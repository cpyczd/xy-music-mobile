/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-06 17:25:09
 * @LastEditTime: 2021-06-06 18:40:51
 */

import 'package:dio/dio.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import '/util/index.dart' as util;

///咪咕音乐
class MgMusicServiceImpl extends BaseMusicService {
  @override
  Future<String> getLyric(MusicEntity entity) async {
    String lrcUrl = entity.originData["lyricUrl"];
    String lrc = await util.HttpUtil.get(lrcUrl, serializationJson: false);
    entity.lrc = lrc;
    return lrc;
  }

  @override
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity) async {
    Map result = await util.HttpUtil.post("https://music.sonimei.cn/",
        data: {"input": entity.hash, "type": "migu", "filter": "id", "page": 1},
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
    Map res = await util.HttpUtil.get(
        "http://jadeite.migu.cn:7090/music_search/v2/search/searchAll",
        data: {
          "sid":
              "4f87090d01c84984a11976b828e2b02c18946be88a6b4c47bcdc92fbd40762db",
          "isCorrect": "1",
          "isCopyright": "1",
          "searchSwitch":
              "%7B%22song%22%3A1%2C%22album%22%3A0%2C%22singer%22%3A0%2C%22tagSong%22%3A1%2C%22mvSong%22%3A0%2C%22bestShow%22%3A1%2C%22songlist%22%3A0%2C%22lyricSong%22%3A0%7D",
          "pageSize": size,
          "text": keyword,
          "pageNo": current,
          "sort": 0,
        },
        options: Options(headers: {
          "sign": "c3b7ae985e2206e97f1b2de8f88691e2",
          "timestamp": "1578225871982",
          "appId": "yyapp2",
          "mode": "android",
          "ua": "Android_migu",
          "version": "6.9.4",
          "osVersion": "android 7.0",
          "User-Agent": "okhttp/3.9.1"
        }));
    if (res["code"] != "000000") {
      return Future.error("搜索失败");
    }
    Map songResultData = Map.from(res["songResultData"]);
    List resultList = songResultData['resultList'] as List;
    return resultList.expand((element) => element).map((e) {
      Map item = Map.from(e);
      Map albumNInfo =
          item.containsKey("albums") && (item["albums"] as List).isNotEmpty
              ? {
                  "id": item["albums"][0]["id"],
                  "name": item["albums"][0]["name"],
                }
              : {"id": null, "name": ""};
      String img =
          item.containsKey("imgItems") && (item["imgItems"] as List).isNotEmpty
              ? item["imgItems"][0]["img"]
              : null;
      MusicEntity entity = MusicEntity(
          songmId: item["songId"],
          albumId: albumNInfo["id"],
          albumName: albumNInfo["name"],
          singer: (item["singers"] as List)
              .map((e) => Map.from(e)["name"])
              .join("、"),
          songName: item['name'],
          picImage: img,
          hash: item["copyrightId"],
          source: MusicSourceConstant.mg,
          duration: Duration.zero,
          durationStr: "-",
          originData: item);
      setQuality(entity, item);
      return entity;
    }).toList();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    //Todo 从设置里获取音频设置
    //默认最高品质
    List rateFormats = map["rateFormats"];
    var qualitys = MusicSupportQualitys.mg.reversed.toList();
    rateFormats.forEach((element) {
      String formatType = element["formatType"];
      String size = element["size"];
      if (formatType == "SQ") {
        entity.quality = qualitys[0];
        entity.qualityFileSize = int.parse(size);
      } else if (formatType == "HQ") {
        entity.quality = qualitys[1];
        entity.qualityFileSize = int.parse(size);
      } else {
        entity.quality = qualitys[2];
        entity.qualityFileSize = int.parse(size);
      }
    });

    return entity;
  }

  @override
  Future<List<String>> getHotSearch() {
    // TODO: implement getHotSearch
    throw UnimplementedError();
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.mg;
  }
}
