/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 16:20:16
 * @LastEditTime: 2021-07-06 16:30:16
 */
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/music/kg_music_service.dart';
import 'package:xy_music_mobile/service/music/mg_music_servce.dart';
import 'package:xy_music_mobile/service/music/tx_music_service.dart';
import 'package:xy_music_mobile/service/music/wy_music_service.dart';
import 'package:xy_music_mobile/util/index.dart';

main() async {
  HttpUtil.logOpen();
  // HttpUtil.openProxy();
  var service = KGMusicServiceImpl();
  // var service = TxMusicServiceImpl();
  // var service = MgMusicServiceImpl();
  // var service = WyMusicServiceImpl();
  List<MusicEntity> res = await service.searchMusic("别错过");
  var music = res[0];
  print(music);
  //获取歌词
  var lrc = await service.getLyric(music);
  var lrcList = service.formatLyric(lrc);
  print("转换后的Lrc对象: $lrcList");
  // print("歌词: \n $lrc");
  //获取图片
  var imgSrc = await service.getPic(music);
  print("ImgSrc: \n $imgSrc");
  //播放Url
  // var playUrl = (await service.getMusicPlayUrl(music)).playUrl;
  // print("PlayUrl: \n $playUrl");
}
