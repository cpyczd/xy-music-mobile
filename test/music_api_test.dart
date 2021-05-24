/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 16:20:16
 * @LastEditTime: 2021-05-24 16:01:12
 */
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/kg_music_service.dart';
import 'package:xy_music_mobile/service/tx_music_service.dart';

main() async {
  // var service = KGMusicServiceImpl();
  var service = TxMusicServiceImpl();
  List<MusicEntity> res = await service.searchMusic("下辈子不一定还能遇见你");
  var music = res[0];
  print(music);
  //获取歌词
  print("歌词: \n ${await service.getLyric(music)}");
  //获取图片
  print("PayUrl: \n ${await service.getMusicPlayUrl(music)}");
}
