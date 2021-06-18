/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 17:36:00
 * @LastEditTime: 2021-06-18 23:09:17
 */
import 'dart:convert';
import 'dart:io';
import 'package:xy_music_mobile/service/kg_music_service.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import 'package:xy_music_mobile/service/square/wy_square_service.dart';
import 'package:xy_music_mobile/util/index.dart';

main() async {
  // MusicService service = KGMusicServiceImpl();
  // var res = await service.getHotSearch();
  // print(res);
  print(WyWebApi()
      .webapi({"s": "晴天", "type": 1, "limit": 10, "offset": (1 - 1) * 10}));
}
