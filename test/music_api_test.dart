/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 16:20:16
 * @LastEditTime: 2021-05-23 20:00:21
 */
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/kg_music_service.dart';

main() async {
  var kg = KGMusicServiceImpl();
  List<MusicEntity> res = await kg.searchMusic("下辈子不一定还能遇见你");
  var music = res[0];
  print(music);
  //获取歌词
  // print("歌词: \n ${await kg.getLyric(music)}");
  //获取图片
  print("PayUrl: \n ${await kg.getMusicPlayUrl(music)}");
}
