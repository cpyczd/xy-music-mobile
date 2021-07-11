/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 11:01:44
 * @LastEditTime: 2021-07-11 19:32:57
 */

import 'package:sqflite_common/sqlite_api.dart';
import 'package:xy_music_mobile/model/song_order_entity.dart';
import 'package:xy_music_mobile/util/orm/orm_base_dao.dart';

class SongGrupDao extends OrmBaseDao<SongGroup> {
  @override
  String getTableCreateSql() {
    return '''
    create table if not exists ${getTableName()} (
      _id INTEGER PRIMARY KEY autoincrement,-- id
      groupName varchar(50) NOT NULL , -- 分组名称
      coverImage text default NULL , -- 封面图片
      createTime INTEGER default NULL,  -- 创建时间
      updateTime INTEGER default NULL -- 更新时间
    );
   ''';
  }

  @override
  String getTableName() {
    return "song_group";
  }

  @override
  void upgrade(Database db, int oldVersion, int newVersion) {}

  @override
  SongGroup parse(Map<String, dynamic> map) {
    return SongGroup.fromMap(map);
  }
}

///分组和歌曲关联表
class SongGrupLinkDao extends OrmBaseDao<SongGoupLink> {
  @override
  String getTableCreateSql() {
    return '''
    create table if not exists ${getTableName()} (
      _id INTEGER PRIMARY KEY autoincrement,-- id
      groupId INTEGER NOT NULL , -- 分组ID
      songId INTEGER default NULL,  -- 歌曲Id
      createTime INTEGER default NULL  -- 创建时间
    );
   ''';
  }

  @override
  String getTableName() {
    return "song_group_link";
  }

  @override
  void upgrade(Database db, int oldVersion, int newVersion) {}

  @override
  SongGoupLink parse(Map<String, dynamic> map) {
    return SongGoupLink.fromMap(map);
  }
}
