/*
 * @Description: 服务注册发现
 * @Author: chenzedeng
 * @Date: 2021-06-14 13:00:03
 * @LastEditTime: 2021-06-14 21:12:25
 */
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/service/kg_music_service.dart';
import 'package:xy_music_mobile/service/mg_music_servce.dart';
import 'package:xy_music_mobile/service/square/kg_square_service.dart';
import 'package:xy_music_mobile/service/tx_music_service.dart';

void _registerMusicService() {
  ///注册酷狗服务
  MusicServiceProviderMange.register(KGMusicServiceImpl());

  ///咪咕服务
  MusicServiceProviderMange.register(MgMusicServiceImpl());

  ///QQ音乐服务
  MusicServiceProviderMange.register(TxMusicServiceImpl());
}

void _registerSquareService() {
  ///酷狗歌单服务注册
  SquareServiceProviderMange.register(KgSquareServiceImpl());
}

void register() {
  _registerMusicService();
  _registerSquareService();
}
