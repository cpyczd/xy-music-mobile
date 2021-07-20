/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 15:20:15
 * @LastEditTime: 2021-07-16 21:24:25
 */
import 'package:sqflite/sqflite.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/util/orm/orm_base_dao.dart';

class SongDao extends OrmBaseDao<MusicEntity> {
  @override
  String getTableCreateSql() {
    return '''
    create table if not exists ${getTableName()} (
      id      INTEGER PRIMARY KEY AUTOINCREMENT,   -- ID
      md5 varchar(100) default NULL , -- md5
      uuid varchar(100) default NULL , -- uuid
      songmId varchar(100) default NULL , -- 歌曲ID
      albumId varchar(100) default NULL , -- 专辑ID
      albumName varchar(100) default NULL , -- 专辑名称
      singer varchar(100) default NULL , -- 歌手
      songName varchar(100) not NULL , -- 歌名
      songnameOriginal varchar(100) default NULL , -- 原始歌名
      source varchar(10) not NULL , -- 来源
      duration INTEGER not NULL , -- 时长
      durationStr varchar(20) default NULL , -- 时长字符串
      picImage text default NULL , -- 图片封面
      lrc text default NULL , -- 歌词
      hash text default NULL , -- Hash
      quality varchar(30) default NULL , -- 音质
      qualityFileSize INTEGER default NULL , -- 音质文件大小
      types text default NULL , -- types
      playUrl text default NULL , -- 音乐播放地址
      originData text default NULL -- 原始数据
    );
   ''';
  }

  @override
  List<String>? initExecSql() {
    return [
      "create index if not exists index_md5 on ${getTableName()} ( md5 )"
    ];
  }

  @override
  String getTableName() {
    return "song";
  }

  @override
  void upgrade(Database db, int oldVersion, int newVersion) {}

  @override
  MusicEntity modelCastFromMap(Map<String, dynamic> map) {
    return MusicEntity.fromMap(map);
  }
}
