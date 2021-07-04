/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-16 16:37:08
 * @LastEditTime: 2021-06-16 16:58:01
 */

import 'package:dio/dio.dart';
import 'package:xy_music_mobile/common/source_constant.dart';

import 'package:xy_music_mobile/model/song_ranking_list_entity.dart';
import 'package:xy_music_mobile/util/index.dart';

import 'dart:async';
import 'package:xy_music_mobile/util/time.dart' show formatPlayTime;
import '../base_music_service.dart';
import '../square/wy_square_service.dart' show WyWebApi;

///网易排行榜解析服务  TODO: 数据较大后期加入缓存
class WyRankingListServiceImpl extends BaseSongRankingService {
  late final WyWebApi webApi;

  WyRankingListServiceImpl() {
    webApi = WyWebApi();
  }

  @override
  Future<List<SongRankingListItemEntity>> getSongList(
      SongRankingListEntity sort,
      {int size = 10,
      int current = 1}) async {
    var params = webApi.webapi({
      "id": sort.id,
      "n": 100000,
      "p": 1,
    });
    Map resp = await HttpUtil.post(
        "https://music.163.com/weapi/v3/playlist/detail",
        urlParams: true,
        data: params);
    if (resp["code"] != 200) {
      return Future.error("请求失败");
    }
    List<String> trackIds = (resp["playlist"]["trackIds"] as List)
        .skip((current - 1) * size)
        .take(size)
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
          "c":
              '[' + trackIds.map((id) => ('{"id":' + id + '}')).join(',') + ']',
          "ids": '[' + trackIds.join(',') + ']',
        }));
    if (resp["code"] != 200) {
      return Future.error("请求失败");
    }
    return (resp["songs"] as List)
        .map((e) => SongRankingListItemEntity(
            id: e["id"].toString(),
            songName: e["name"],
            singer: (e["ar"] as List).map((e) => e["name"]).join("、"),
            album: e["al"]["name"],
            originalData: e,
            duration: Duration(milliseconds: e["dt"]),
            durationStr: formatPlayTime(e["dt"] / 1000),
            source: MusicSourceConstant.wy))
        .toList();
  }

  @override
  FutureOr<List<SongRankingListEntity>> getSortList() {
    return [
      SongRankingListEntity(
          id: "19723756", name: "云音乐飙升榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3778678", name: "云音乐热歌榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3779629", name: "云音乐新歌榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2884035", name: "云音乐原创榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2250011882", name: "抖音排行榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "1978921795", name: "云音乐电音榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "4395559", name: "华语金曲榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "71384707", name: "云音乐古典音乐榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "10520166", name: "云音乐国电榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2006508653", name: "电竞音乐榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "991319590", name: "云音乐说唱榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "180106", name: "UK排行榜周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "60198", name: "美国Billboard周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "21845217", name: "KTV嗨榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "11641012", name: "iTunes榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "120001", name: "Hit FM Top榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "60131", name: "日本Oricon周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3733003", name: "韩国Melon排行榜周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "60255", name: "韩国Mnet排行榜周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "46772709", name: "韩国Melon原声周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "64016", name: "中国TOP排行榜(内地榜)", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "112504", name: "中国TOP排行榜(港台榜)", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3112516681", name: "中国新乡村音乐排行榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "10169002", name: "香港电台中文歌曲龙虎榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "27135204",
          name: "法国 NRJ EuroHot 30周榜",
          source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "1899724", name: "中国嘻哈榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "112463", name: "台湾Hito排行榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3812895",
          name: "Beatport全球电子舞曲榜",
          source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2617766278", name: "新声榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "745956260", name: "云音乐韩语榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2847251561", name: "说唱TOP榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2023401535", name: "英国Q杂志中文版周榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2809513713", name: "云音乐欧美热歌榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "2809577409", name: "云音乐欧美新歌榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "71385702", name: "云音乐ACG音乐榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3001835560", name: "云音乐ACG动画榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3001795926", name: "云音乐ACG游戏榜", source: MusicSourceConstant.wy),
      SongRankingListEntity(
          id: "3001890046",
          name: "云音乐ACG VOCALOID榜",
          source: MusicSourceConstant.wy),
    ];
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.wy;
  }
}
