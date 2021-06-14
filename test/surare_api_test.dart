/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-14 21:40:33
 * @LastEditTime: 2021-06-14 22:27:12
 */
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/service/music_service.dart';
import 'package:xy_music_mobile/service/square/kg_square_service.dart';

main() async {
  SongSquareService service = KgSquareServiceImpl();

  var songList = await service.getSongMusicList(SongSquareInfo(
      id: "182367",
      playCount: "1",
      collectCount: "1",
      name: "name",
      time: "time",
      img: "img",
      grade: 1,
      desc: "desc",
      author: "author"));

  print(songList.length);
}
