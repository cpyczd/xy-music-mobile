/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 18:29:30
 * @LastEditTime: 2021-07-16 23:03:39
 */
import 'dart:async';

import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/setting_configuration.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_ranking_list_entity.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/common/source_constant.dart';

///公共抽象类
abstract class BaseCommon {
  ///返回支持的解析源
  MusicSourceConstant? supportSource({Object? fliter});

  ///返回是否支持此解析源
  support(MusicSourceConstant type, {Object? fliter}) {
    MusicSourceConstant? source = supportSource(fliter: fliter);
    return source != null && source == type;
  }
}

///解析音乐播放地址抽象类
abstract class BaseParseMusicPlayUrl {
  PlayUrlParseRoutesEnum getParseRoute();

  ///获取解析音乐播放Url地址
  Future<String> parsePlayUrl(MusicEntity entity);
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

  ///返回所有支持的解析路线
  List<BaseParseMusicPlayUrl> getParseRouters();

  ///返回播放的地址Url
  Future<MusicEntity> getPlayUrl(MusicEntity entity) async {
    var config = SettingsConfiguration.getConfigureMusicParseRoute();
    if (getParseRouters().isEmpty) {
      throw Exception("No parser");
    }
    if (config == PlayUrlParseRoutesEnum.STABLE) {
      for (var parse in getParseRouters()) {
        try {
          String url = await parse.parsePlayUrl(entity);
          if (url.isNotEmpty) {
            entity.playUrl = url;
            return entity;
          }
        } catch (e) {
          log.e(
              "解析播放地址失败: 音乐${entity.songName} 源:${entity.source} 解析器:${parse.getParseRoute()}",
              e);
          continue;
        }
      }
    } else {
      BaseParseMusicPlayUrl route;
      try {
        route = getParseRouters()
            .firstWhere((element) => element.getParseRoute() == config);
      } on StateError {
        route = getParseRouters()[0];
        log.d(
            "没有找到此配置默认选择第一个路由作为解析器===> 音乐${entity.songName} 源:${entity.source} 解析器:${route.getParseRoute()}");
      }
      try {
        String url = await route.parsePlayUrl(entity);
        if (url.isNotEmpty) {
          entity.playUrl = url;
          return entity;
        }
      } catch (e) {
        return Future.error(e);
      }
    }
    return Future.error("解析失败");
  }

  ///解析歌词
  List<Lyric> formatLyric(String lyricStr);

  ///获取品质
  MusicEntity setQuality(MusicEntity entity, Map map);
}

///歌单广场抽象类
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

  ///转换成MusicEntity对象
  Future<MusicEntity> toMusicModel(SongSquareMusic music);
}

///歌曲排行榜服务抽象类
abstract class BaseSongRankingService extends BaseCommon {
  ///获取到分类数据
  FutureOr<List<SongRankingListEntity>> getSortList();

  ///获取到歌曲数据列表
  Future<List<SongRankingListItemEntity>> getSongList(
      SongRankingListEntity sort,
      {int size = 10,
      int current = 1});
}
