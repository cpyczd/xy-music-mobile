/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-26 20:19:46
 * @LastEditTime: 2021-05-26 22:16:37
 */
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/music_service.dart';
import '/util/index.dart' as util;

class WyMusicServiceImpl extends MusicService {
  @override
  Future<String> getLyric(MusicEntity entity) {
    // TODO: implement getLyric
    throw UnimplementedError();
  }

  @override
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity) {
    // TODO: implement getMusicPlayUrl
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getMusicSquareDetail(
      Map<String, dynamic> params) {
    // TODO: implement getMusicSquareDetail
    throw UnimplementedError();
  }

  @override
  Future<String> getPic(MusicEntity entity) {
    // TODO: implement getPic
    throw UnimplementedError();
  }

  @override
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0}) {
    // TODO: implement searchMusic
    throw UnimplementedError();
  }

  @override
  MusicEntity setQuality(MusicEntity entity, Map map) {
    // TODO: implement setQuality
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getHotSearch() {
    // TODO: implement getHotSearch
    throw UnimplementedError();
  }
}
