/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 11:01:44
 * @LastEditTime: 2021-07-20 13:35:31
 */

import 'package:sqflite_common/sqlite_api.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/model/song_order_entity.dart';
import 'package:xy_music_mobile/util/orm/orm_base_dao.dart';

class SongGrupDao extends OrmBaseDao<SongGroup> {
  static const int LIKE_ID = 1;

  @override
  String getTableCreateSql() {
    return '''
    CREATE TABLE IF NOT EXISTS ${getTableName()} (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,-- id
      groupName  VARCHAR(50) NOT NULL , -- 分组名称
      coverImage TEXT DEFAULT NULL , -- 封面图片
      createTime INTEGER DEFAULT NULL,  -- 创建时间
      updateTime INTEGER DEFAULT NULL -- 更新时间
    );
   ''';
  }

  @override
  List<String>? initExecSql() {
    return [
      '''
      INSERT INTO ${getTableName()} (id,groupName,createTime) VALUES($LIKE_ID,'我喜欢的音乐',${DateTime.now().millisecondsSinceEpoch})
      '''
    ];
  }

  @override
  String getTableName() {
    return "song_group";
  }

  @override
  void upgrade(Database db, int oldVersion, int newVersion) {}

  @override
  SongGroup modelCastFromMap(Map<String, dynamic> map) {
    log.i("modelCastFromMap===>>>> $map");
    return SongGroup.fromMap(map);
  }
}

///分组和歌曲关联表
class SongGrupLinkDao extends OrmBaseDao<SongGoupLink> {
  @override
  String getTableCreateSql() {
    return '''
    create table if not exists ${getTableName()} (
      id      INTEGER PRIMARY KEY AUTOINCREMENT,-- id
      groupId INTEGER NOT NULL , -- 分组ID
      songId INTEGER default NULL,  -- 歌曲Id
      createTime INTEGER default NULL  -- 创建时间
    );
   ''';
  }

  @override
  List<String>? initExecSql() {
    return [
      "create index if not exists group_id_key on ${getTableName()} ( groupId )"
    ];
  }

  @override
  String getTableName() {
    return "song_group_link";
  }

  @override
  void upgrade(Database db, int oldVersion, int newVersion) {}

  @override
  SongGoupLink modelCastFromMap(Map<String, dynamic> map) {
    return SongGoupLink.fromMap(map);
  }
}
