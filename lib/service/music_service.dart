/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 18:29:30
 * @LastEditTime: 2021-06-14 21:00:52
 */
import 'dart:async';

import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';

abstract class MusicService {
  ///搜索
  Future<List<MusicEntity>> searchMusic(String keyword,
      {int size = 10, int current = 0});

  ///获取歌词
  Future<String> getLyric(MusicEntity entity);

  ///获取图片
  Future<String> getPic(MusicEntity entity);

  ///获取热搜词
  Future<List<String>> getHotSearch();

  ///获取音乐详情
  Future<MusicEntity> getMusicPlayUrl(MusicEntity entity);

  MusicEntity setQuality(MusicEntity entity, Map map);

  ///所支持的播放源
  bool support(MusicSourceConstant type, Object? fliter);
}

///歌单广场
abstract class SongSquareService {
  ///返回类别列表信息
  FutureOr<List<SongSquareSort>> getSortList();

  ///返回Tag标签列表
  Future<List<SongSqurareTag>> getTags();

  ///返回歌单列表信息数据
  Future<List<SongSquareInfo>> getSongSquareInfoList(
      {SongSquareSort? sort, SongSqurareTagItem? tag, int page = 1});

  ///获取歌单内音乐列表信息
  Future<List<SongSquareMusic>> getSongMusicList(SongSquareInfo info,
      {int size = 10, int current = 1});

  ///所支持的播放源
  bool support(MusicSourceConstant type, Object? fliter);
}
