/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 18:29:30
 * @LastEditTime: 2021-05-23 19:53:37
 */
import 'package:xy_music_mobile/model/music_entity.dart';

abstract class MusicService {
  ///搜索
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0});

  ///获取歌词
  Future<String> getLyric(MusicEntity entity);

  ///获取图片
  Future<String> getPic(MusicEntity entity);

  ///获取排行榜
  //Future<List<MusicEntity>> getHotRankings(Map<String, dynamic> params);

  ///获取歌单
  //Future<List<Map<String, dynamic>>> getMusicSquare(Map<String, dynamic> params);

  ///获取歌单详情
  Future<List<Map<String, dynamic>>> getMusicSquareDetail(
      Map<String, dynamic> params);

  ///获取热搜词
  //List<String> getHotSearch(Map<String, dynamic> params);

  ///获取评论
  //List<Map<String, dynamic>> getComment(Map<String, dynamic> params);

  ///获取音乐详情
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity);

  MusicEntity setQuality(MusicEntity entity, Map map);
}
