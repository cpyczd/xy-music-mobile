/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-14 21:02:06
 * @LastEditTime: 2021-06-20 16:48:22
 */

import 'dart:convert';

import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'dart:async';
import 'package:xy_music_mobile/util/http_util.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/time.dart' show formatPlayTime;
import '../base_music_service.dart';

///酷狗歌单Service    Todo: 后期接口需要接入缓存存储、优化IO性能开销与内存开销
class KgSquareServiceImpl extends BaseSongSquareService {
  @override
  Future<List<SongSquareMusic>> getSongMusicList(SongSquareInfo info,
      {int size = 10, int current = 1}) async {
    String resp = await HttpUtil.get(
        "http://www2.kugou.kugou.com/yueku/v9/special/single/${info.id}-5-9999.html",
        serializationJson: false);
    var s = RegExp(r"global.data = (\[.+\]);").stringMatch(resp);
    if (s != null) {
      s = s.replaceAll("global.data =", "");
      s = s.replaceAll(";", "");
      List sl = json.decode(s);
      return sl
          .map((e) => SongSquareMusic(
              id: e["hash"],
              songName: e["songname"],
              singer: e["singername"],
              album: e["album_name"],
              source: MusicSourceConstant.kg,
              duration: Duration(seconds: e["duration"]),
              durationStr:
                  getTimeStamp(Duration(seconds: e["duration"]).inMilliseconds),
              originalData: e))
          .skip((current - 1) * size)
          .take(size)
          .toList();
    }
    return Future.error("获取失败");
  }

  @override
  Future<List<SongSquareInfo>> getSongSquareInfoList(
      {SongSquareSort? sort,
      SongSqurareTagItem? tag,
      int page = 1,
      int size = 10}) async {
    Map resp = await HttpUtil.get(
        "http://www2.kugou.kugou.com/yueku/v9/special/getSpecial",
        data: {
          "is_ajax": 1,
          "cdn": "cdn",
          "t": sort?.id ?? "",
          "c": tag?.id ?? "",
          "p": page - 1
        });
    if (resp["status"] != 1) {
      Future.error("获取失败");
    }
    return (resp["special_db"] as List)
        .map((e) => SongSquareInfo(
            id: e["specialid"].toString(),
            playCount: e["total_play_count"].toString(),
            collectCount: e["collect_count"].toString(),
            name: e["specialname"],
            time: e["publish_time"],
            img: e["img"],
            grade: double.parse(e["grade"].toString()),
            desc: e["intro"],
            author: e["nickname"]))
        .toList();
  }

  @override
  FutureOr<List<SongSquareSort>> getSortList() {
    return [
      SongSquareSort(id: "", name: "全部"),
      SongSquareSort(id: "5", name: "推荐"),
      SongSquareSort(id: "6", name: "最热"),
      SongSquareSort(id: "7", name: "最新"),
      SongSquareSort(id: "3", name: "热藏"),
      SongSquareSort(id: "8", name: "飙升"),
    ];
  }

  @override
  Future<List<SongSqurareTag>> getTags() async {
    Map response = await HttpUtil.get(
        "http://www2.kugou.kugou.com/yueku/v9/special/getSpecial?is_smarty=1&=");

    if (response["status"] != 1) {
      Future.error("获取失败");
    }
    var tagIds = Map<String, dynamic>.from(response["data"]["tagids"]);
    var tagList = <SongSqurareTag>[];
    for (MapEntry<String, dynamic> item in tagIds.entries) {
      var tag = SongSqurareTag(name: item.key, source: MusicSourceConstant.kg);
      var tagInfoList = (item.value["data"] as List)
          .map((e) => SongSqurareTagItem(
              name: e["name"],
              parentName: e["pname"],
              id: e["id"].toString(),
              parentId: e["parent_id"].toString()))
          .toList();
      tag.tags = tagInfoList;
      tagList.add(tag);
    }
    return tagList;
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.kg;
  }
}
