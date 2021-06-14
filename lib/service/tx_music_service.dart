/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-24 14:33:31
 * @LastEditTime: 2021-06-06 18:42:43
 */
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';

import 'music_service.dart';
import '/util/index.dart' as util;

///QQ音乐解析服务
class TxMusicServiceImpl extends MusicService {
  @override
  Future<String> getLyric(MusicEntity entity) async {
    Map result = await util.HttpUtil.get(
        "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg",
        data: {
          "songmid": entity.hash,
          "g_tk": "5381",
          "loginUin": 0,
          "hostUin": 0,
          "format": "json",
          "inCharset": "utf8",
          "outCharset": "utf-8",
          "platform": "yqq"
        },
        options: Options(
            headers: {"Referer": "https://y.qq.com/portal/player.html"}));
    if (result["code"] != 0) {
      return Future.error("获取歌词失败");
    }
    String code = result["lyric"];
    if (code.isEmpty) {
      return Future.error("获取歌词失败");
    }
    entity.lrc = Utf8Decoder().convert(base64Decode(code));
    return entity.lrc!;
  }

  @override
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity) async {
    Map result = await util.HttpUtil.post("https://music.sonimei.cn/",
        data: {"input": entity.hash, "type": "qq", "filter": "id", "page": 1},
        options: Options(headers: {
          "x-requested-with": "XMLHttpRequest",
          "Content-Type": "multipart/form-data"
        }));
    if (result["code"] != 200) {
      return Future.error("解析失败");
    }
    entity.playUrl = result["data"]["url"];
    return entity;
  }

  @override
  Future<String> getPic(MusicEntity entity) {
    return Future.value(entity.picImage);
  }

  @override
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0}) async {
    Map result = await util.HttpUtil.get(
        "https://c.y.qq.com/soso/fcgi-bin/client_search_cp",
        data: {
          "ct": 24,
          "qqmusic_ver": 1298,
          "new_json": 1,
          "remoteplace": "txt.yqq.top",
          "searchid": 1,
          "aggr": 1,
          "cr": 1,
          "catZhida": 1,
          "lossless": 0,
          "flag_qc": 0,
          "p": current,
          "n": size,
          "w": keyword,
          "cv": 4747474,
          "format": "json",
          "inCharset": "utf-8",
          "outCharset": "utf-8",
          "notice": 0,
          "platform": "yqq.json",
          "needNewCode": 0,
          "uin": 0,
          "hostUin": 0,
          "loginUin": 0
        });

    if (result["code"] != 0) {
      return Future.error("搜索失败");
    }
    return (result["data"]["song"]["list"] as List).map((e) {
      var map = Map<String, dynamic>.from(e);
      String singer = (map["singer"] as List).map((e) => e["name"]).join("、");
      var entity = MusicEntity(
          songmId: map["id"].toString(),
          albumId: map["album"]["id"].toString(),
          albumName: map["album"]["title"],
          singer: singer,
          hash: map["mid"].toString(),
          songName: map["title"],
          songnameOriginal: map["name"],
          source: MusicSourceConstant.tx,
          duration: map["interval"],
          durationStr: util.getTimeStamp(map["interval"]),
          picImage: ((map["album"]["name"] as String).isEmpty ||
                  (map["album"]["name"] as String) == '空')
              ? "https://y.gtimg.cn/music/photo_new/T001R500x500M000${map['singer'][0]['mid']}.jpg"
              : "https://y.gtimg.cn/music/photo_new/T002R500x500M000${map['album']['mid']}.jpg",
          originData: map);
      return setQuality(entity, map);
    }).toList();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    Map file = map["file"];
    //默认最高品质
    var qualitys = MusicSupportQualitys.tx.reversed.toList();
    if (file["size_flac"] != 0) {
      entity.quality = qualitys[0];
      entity.qualityFileSize = file["size_flac"];
    } else if (file["size_320mp3"] != 0) {
      entity.quality = qualitys[1];
      entity.qualityFileSize = file["size_320mp3"];
    } else if (file["size_128mp3"] != 0) {
      entity.quality = qualitys[2];
      entity.qualityFileSize = file["size_128mp3"];
    }
    return entity;
  }

  @override
  Future<List<String>> getHotSearch() {
    // TODO: implement getHotSearch
    throw UnimplementedError();
  }

  @override
  bool support(MusicSourceConstant type, Object? fliter) {
    return type == MusicSourceConstant.tx;
  }
}
