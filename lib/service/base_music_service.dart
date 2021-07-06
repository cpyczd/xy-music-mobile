/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 18:29:30
 * @LastEditTime: 2021-07-06 15:54:24
 */
import 'dart:async';

import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_ranking_list_entity.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/common/source_constant.dart';

///公共抽象类
abstract class BaseCommon {
  MusicSourceConstant? supportSource({Object? fliter});

  ///所支持的播放源
  support(MusicSourceConstant type, {Object? fliter}) {
    MusicSourceConstant? source = supportSource(fliter: fliter);
    return source != null && source == type;
  }
}

///音乐解析服务抽象类
abstract class BaseMusicService extends BaseCommon {
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

  ///解析歌词
  List<Lyric> formatLyric(String lyricStr);

  ///获取品质
  MusicEntity setQuality(MusicEntity entity, Map map);
}

///歌单广场
abstract class BaseSongSquareService extends BaseCommon {
  ///返回类别列表信息
  FutureOr<List<SongSquareSort>> getSortList();

  ///返回Tag标签列表
  Future<List<SongSqurareTag>> getTags();

  ///返回歌单列表信息数据
  Future<List<SongSquareInfo>> getSongSquareInfoList(
      {SongSquareSort? sort,
      SongSqurareTagItem? tag,
      int page = 1,
      int size = 10});

  ///获取歌单内音乐列表信息
  Future<List<SongSquareMusic>> getSongMusicList(SongSquareInfo info,
      {int size = 10, int current = 1});
}

///歌曲排行榜服务
abstract class BaseSongRankingService extends BaseCommon {
  ///获取到分类数据
  FutureOr<List<SongRankingListEntity>> getSortList();

  ///获取到歌曲数据列表
  Future<List<SongRankingListItemEntity>> getSongList(
      SongRankingListEntity sort,
      {int size = 10,
      int current = 1});
}
