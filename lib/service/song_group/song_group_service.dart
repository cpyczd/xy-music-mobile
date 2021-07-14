/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-12 10:26:31
 * @LastEditTime: 2021-07-14 17:44:22
 */

import 'package:xy_music_mobile/dao/song_dao.dart';
import 'package:xy_music_mobile/dao/song_group_dao.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_order_entity.dart';

class SongGroupService {
  static final SongDao _songDao = SongDao();
  static final SongGrupDao _songGrupDao = SongGrupDao();
  static final SongGrupLinkDao _songGrupLinkDao = SongGrupLinkDao();

  ///创建一个分组
  Future<SongGroup> createGroup(SongGroup group) {
    group.id = null;
    return _songGrupDao.insert(group);
  }

  ///更新一个分组
  Future<bool> updateGroup(SongGroup update) async {
    SongGroup? group = await _songGrupDao.getOne(update.id!);
    if (group == null) {
      return false;
    }
    var row = await _songGrupDao.updateById(update);
    return row > 0;
  }

  ///更新一个音乐数据
  Future<bool> updateMusic(MusicEntity music) async {
    MusicEntity? entity = await _songDao.getOne(music.id!);
    if (entity == null) {
      return false;
    }
    var row = await _songDao.updateById(music);
    return row > 0;
  }

  ///添加一首音乐到分组里
  Future<void> addMusic(int groupId, MusicEntity entity) async {
    entity.id = null;
    MusicEntity saveEntity = await _songDao.insert(entity);
    SongGoupLink link = SongGoupLink(groupId: groupId, songId: saveEntity.id!);
    await _songGrupLinkDao.insert(link);
  }

  ///删除一个音乐
  Future<bool> deleteMusicByLinkId(int id) async {
    var link = await _songGrupLinkDao.getOne(id);
    if (link != null) {
      int row = await _songDao.deleteById(link.songId);
      if (row <= 0) {
        return false;
      }
      row = await _songGrupLinkDao.deleteById(id);
      return row > 0;
    }
    return false;
  }

  ///删除一个分组根据Id
  Future<bool> deleteGroupById(int id) async {
    int row = await _songGrupDao.deleteById(id);
    if (row <= 0) {
      return false;
    }
    //删除分组关联Link表和音乐主表
    var database = await _songGrupLinkDao.getDataBase();
    row = await database.delete(
        "delete from sl,s from ${_songGrupLinkDao.getTableName()} as sl" +
            " left join ${_songDao.getTableName()} as s on sl.songId = s._id" +
            " where sl.groupId = $id");
    return row > 0;
  }
}
