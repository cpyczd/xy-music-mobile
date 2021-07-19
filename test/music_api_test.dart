/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 16:20:16
 * @LastEditTime: 2021-07-11 13:23:41
 */
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/music/kg_music_service.dart';
import 'package:xy_music_mobile/service/music/kw_msuic_service.dart';
import 'package:xy_music_mobile/service/music/mg_music_servce.dart';
import 'package:xy_music_mobile/service/music/tx_music_service.dart';
import 'package:xy_music_mobile/service/music/wy_music_service.dart';
import 'package:xy_music_mobile/util/index.dart';

main() async {
  HttpUtil.logOpen();
  // HttpUtil.openProxy();
  // var service = KGMusicServiceImpl();
  // var service = TxMusicServiceImpl();
  var service = MgMusicServiceImpl();
  // var service = WyMusicServiceImpl();
  // var service = KwMusicServiceImpl();
  List<MusicEntity> res = await service.searchMusic("嘉宾");
  var music = res[0];
  log.d("原始Music[0]====>>>$music");
  //获取歌词
  var lrc = await service.getLyric(music);
  var lrcList = service.formatLyric(lrc);
  print("转换后的Lrc对象: $lrcList");
  print("歌词: \n $lrc");
  log.d("转换后Music[0]====>>>$music");
  //获取图片
  var imgSrc = await service.getPic(music);
  print("ImgSrc: \n $imgSrc");
  //播放Url
  // var playUrl = (await service.getMusicPlayUrl(music)).playUrl;
  // print("PlayUrl: \n $playUrl");
}
