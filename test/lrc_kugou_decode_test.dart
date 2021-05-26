/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 17:36:00
 * @LastEditTime: 2021-05-26 22:17:13
 */
import 'dart:convert';
import 'dart:io';
import 'package:xy_music_mobile/service/kg_music_service.dart';
import 'package:xy_music_mobile/service/music_service.dart';
import 'package:xy_music_mobile/util/index.dart';

main() async {
  MusicService service = KGMusicServiceImpl();
  var res = await service.getHotSearch();
  print(res);
}
