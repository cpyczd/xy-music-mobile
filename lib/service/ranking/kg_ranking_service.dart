/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-16 15:15:38
 * @LastEditTime: 2021-06-16 16:12:33
 */
import 'dart:convert';

import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/model/song_ranking_list_entity.dart';
import 'dart:async';
import 'package:xy_music_mobile/util/time.dart' show formatPlayTime;
import 'package:xy_music_mobile/util/index.dart';
import '../base_music_service.dart';

///酷狗排行榜服务
class KgRankingListServiceImpl extends BaseSongRankingService {
  @override
  Future<List<SongRankingListItemEntity>> getSongList(
      SongRankingListEntity sort,
      {int size = 10,
      int current = 1}) async {
    String resp = await HttpUtil.get(
        "http://www2.kugou.kugou.com/yueku/v9/rank/home/$current-${sort.id}.html",
        serializationJson: false);
    var total = RegExp(r"total: '(\d+)',")
        .stringMatch(resp)
        ?.replaceAll(RegExp(r"(\D)"), "");
    var page = RegExp(r"page: '(\d+)',")
        .stringMatch(resp)
        ?.replaceAll(RegExp(r"(\D)"), "");
    var limit = RegExp(r"pagesize: '(\d+)',")
        .stringMatch(resp)
        ?.replaceAll(RegExp(r"(\D)"), "");
    var listData = RegExp(r"global.features = (\[.+\]);").stringMatch(resp);
    if (listData == null) {
      return Future.error("获取失败");
    }
    listData = listData.substring(listData.indexOf("[") - 1);
    listData = listData.substring(0, listData.lastIndexOf("]") + 1);
    List list = json.decode(listData);
    return list
        .map((e) => SongRankingListItemEntity(
            id: e["HASH"],
            songName: e["songname"],
            singer: e["singername"],
            album: e["album_name"],
            duration: e["duration"],
            durationStr: formatPlayTime(e["duration"] / 1000),
            source: MusicSourceConstant.kg,
            originalData: e))
        .toList();
  }

  @override
  FutureOr<List<SongRankingListEntity>> getSortList() {
    return [
      SongRankingListEntity(
          id: "8888", name: "酷狗TOP500", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "6666", name: "酷狗飙升榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "37361", name: "酷狗雷达榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "23784", name: "网络红歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "24971", name: "DJ热歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "35811", name: "会员专享热歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "31308", name: "华语新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "31310", name: "欧美新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "31311", name: "韩国新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "31312", name: "日本新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "31313", name: "粤语新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "33162", name: "ACG新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "21101", name: "酷狗分享榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "30972", name: "腾讯音乐人原创榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "22603", name: "5sing音乐榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "33160", name: "电音热歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "21335", name: "繁星音乐榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "33161", name: "古风新歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "33163", name: "影视金曲榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "33166", name: "欧美金曲榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "33165", name: "粤语金曲榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "36107", name: "小语种热歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "4681", name: "美国BillBoard榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "4680", name: "英国单曲榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "4673", name: "日本公信榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "38623", name: "韩国Melon音乐榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "42807", name: "joox本地热歌榜", source: MusicSourceConstant.kg),
      SongRankingListEntity(
          id: "42808", name: "台湾KKBOX风云榜", source: MusicSourceConstant.kg)
    ];
  }

  @override
  MusicSourceConstant? supportSource({Object? fliter}) {
    return MusicSourceConstant.kg;
  }
}
