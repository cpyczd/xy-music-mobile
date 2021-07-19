/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-16 15:40:29
 * @LastEditTime: 2021-06-16 16:46:34
 */

import 'package:logger/logger.dart';
import 'package:xy_music_mobile/model/song_ranking_list_entity.dart';
import 'package:xy_music_mobile/service/ranking/kg_ranking_service.dart';
import 'package:xy_music_mobile/service/ranking/wy_ranking_service.dart';
import 'package:xy_music_mobile/util/index.dart';

main() async {
  var log = Logger();
  HttpUtil.logOpen();
  HttpUtil.openProxy();
  // var service = KgRankingListServiceImpl();
  var service = WyRankingListServiceImpl();

  List<SongRankingListEntity> sortList =
      service.getSortList() as List<SongRankingListEntity>;

  var songList = await service.getSongList(sortList[0]);

  log.i(songList);
}
