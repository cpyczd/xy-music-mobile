/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-12 10:26:31
 * @LastEditTime: 2021-07-15 23:48:12
 */

import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/dao/song_dao.dart';
import 'package:xy_music_mobile/dao/song_group_dao.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_order_entity.dart';
import 'package:xy_music_mobile/util/orm/orm_query_wapper.dart';

class SongGroupService {
  static final SongDao _songDao = SongDao();
  static final SongGrupDao _songGrupDao = SongGrupDao();
  static final SongGrupLinkDao _songGrupLinkDao = SongGrupLinkDao();

  ///返回系统默认自带的歌单Id编号
  static int getLikeId() {
    return SongGrupDao.LIKE_ID;
  }

  ///查询所有的分组数据
  Future<List<SongGroup>> findAllGroup() async {
    var list = await _songGrupDao.list();
    for (var g in list) {
      int count = await _songGrupLinkDao.count(
          wapper: QueryWapper<SongGoupLink>().eq("groupId", g.id!));
      g.musicCount = count;
    }
    return list;
  }

  Future<SongGroup?> findGroupById(int id) async {
    var group = await _songGrupDao.getOne(id);
    if (group == null) {
      return null;
    }
    int count = await _songGrupLinkDao.count(
        wapper: QueryWapper<SongGoupLink>().eq("groupId", group.id!));
    group.musicCount = count;
    return group;
  }

  ///查询所有的音乐列表
  Future<List<MusicEntity>> findAllMusicByGroupId(int groupId) async {
    var linkList = await _songGrupLinkDao
        .listByQueryWapper(QueryWapper<SongGoupLink>().eq("groupId", groupId));
    return _songDao.listByQueryWapper(QueryWapper<MusicEntity>()
        .eqIn("id", linkList.map((e) => e.songId).toList()));
  }

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
    log.i("保存的音乐:===>>>> $saveEntity");
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
    if (id == SongGrupDao.LIKE_ID) {
      log.w("系统初始化【我的喜欢音乐】歌单无法删除");
      return false;
    }
    int row = await _songGrupDao.deleteById(id);
    if (row <= 0) {
      return false;
    }
    var links = await _songGrupLinkDao
        .listByQueryWapper(QueryWapper<SongGoupLink>().eq("groupId", id));
    for (var element in links) {
      await _songDao.deleteById(element.songId);
    }
    row = await _songGrupLinkDao
        .deleteByQueryWapper(QueryWapper<SongGoupLink>().eq("groupId", id));
    return row > 0;
  }

  ///判断此音乐是否存在我的喜欢列表中
  Future<bool> existMusicLike(String md5) async {
    var database = await _songDao.getDataBase();
    var res = await database.rawQuery('''
      SELECT COUNT(S.id) AS COUNT FROM ${_songGrupLinkDao.getTableName()} AS SL
      LEFT JOIN ${_songDao.getTableName()} AS S
      ON S.id = SL.songId
      WHERE SL.groupId = ${getLikeId()}
      AND S.md5 = '$md5'
      ''');
    if (res.isEmpty) {
      return false;
    }
    return (res[0]["COUNT"] as int) > 0;
  }

  ///删除一个音乐数据
  Future<bool> deleteLikeMusicByMD5(String md5) async {
    var database = await _songDao.getDataBase();
    var res = await database.rawQuery('''
      select s.id from ${_songGrupLinkDao.getTableName()} as sl
      left join ${_songDao.getTableName()} as s on sl.songId = s.id
      where sl.groupId = ${getLikeId()} and s.md5 = '$md5';
      ''');
    int row = -1;
    if (res.isNotEmpty) {
      int musicId = int.parse(res[0]["id"]!.toString());
      row = await _songGrupLinkDao.deleteByQueryWapper(
          QueryWapper<SongGoupLink>()
              .eq("groupId", getLikeId())
              .eq("songId", musicId));
      if (row <= 0) {
        return false;
      }
      row = await _songDao.deleteById(musicId);
      if (row <= 0) {
        return false;
      }
    }
    return true;
  }
}
