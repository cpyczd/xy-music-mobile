/*
 * @Description: 服务注册发现
 * @Author: chenzedeng
 * @Date: 2021-06-14 13:00:03
 * @LastEditTime: 2021-06-16 11:02:05
 */
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/service/kg_music_service.dart';
import 'package:xy_music_mobile/service/mg_music_servce.dart';
import 'package:xy_music_mobile/service/square/kg_square_service.dart';
import 'package:xy_music_mobile/service/tx_music_service.dart';

///音乐服务
void _registerMusicService() {
  ///注册酷狗服务
  MusicServiceProviderMange.register(KGMusicServiceImpl());

  ///咪咕服务
  MusicServiceProviderMange.register(MgMusicServiceImpl());

  ///QQ音乐服务
  MusicServiceProviderMange.register(TxMusicServiceImpl());
}

///歌单服务
void _registerSquareService() {
  ///酷狗歌单服务注册
  SquareServiceProviderMange.register(KgSquareServiceImpl());
}

///注册服务方法、调用交给Application类去管理
void register() {
  _registerMusicService();
  _registerSquareService();
}
