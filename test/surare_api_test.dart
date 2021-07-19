/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-14 21:40:33
 * @LastEditTime: 2021-06-15 23:26:12
 */
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import 'package:xy_music_mobile/service/square/kg_square_service.dart';
import 'package:xy_music_mobile/service/square/wy_square_service.dart';
import 'package:xy_music_mobile/util/http_util.dart';

main() async {
  HttpUtil.logOpen();
  HttpUtil.openProxy();
  // SongSquareService service = WySquareServiceImpl();
  BaseSongSquareService service = KgSquareServiceImpl();

  var infoList = await service.getSongSquareInfoList();

  print(infoList);

  // var songList = await service.getSongMusicList(SongSquareInfo(
  //     id: "6654565519",
  //     playCount: "1",
  //     collectCount: "1",
  //     name: "name",
  //     time: "time",
  //     img: "img",
  //     grade: 1,
  //     desc: "desc",
  //     author: "author"));
  // print(songList);
  // var tags = await service.getTags();
  // print(tags);
}
