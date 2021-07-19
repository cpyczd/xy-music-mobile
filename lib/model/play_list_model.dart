import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 17:40:45
 * @LastEditTime: 2021-07-06 21:33:35
 */
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:hive/hive.dart';
import 'music_entity.dart';
part 'play_list_model.g.dart';

///当前音乐播放列表
@HiveType(typeId: 1)
class PlayListModel extends HiveObject {
  //播放列表
  @HiveField(0)
  List<MusicEntity> musicList;

  //播放模式
  @HiveField(1)
  PlayMode mode;

  ///播放的歌曲下标
  @HiveField(2)
  int currentIndex;

  MusicEntity? currentMusic;

  Random? _random;

  VoidCallback? _save;

  var _uuid = Uuid();

  PlayListModel({
    required this.musicList,
    this.mode = PlayMode.order,
    this.currentIndex = 0,
  }) {
    //初始化赋值
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    if (musicList.isNotEmpty && musicList.length > currentIndex) {
      currentMusic = musicList[currentIndex];
    }
    for (var v in this.musicList) {
      _checkData(v);
    }
  }

  void _checkData(MusicEntity entity) async {
    if (entity.uuid == null || entity.uuid!.isEmpty) {
      entity.uuid = _uuid.v1();
    }
    if (entity.picImage == null || entity.picImage!.isEmpty) {
      var url = await musicServiceProviderMange
          .getSupportProvider(entity.source)
          .first
          .getPic(entity);
      entity.picImage = url;
    }
  }

  ///根据UUID查找
  MusicEntity? findByUuid(String uuid) {
    var index = this.musicList.indexWhere((element) => element.uuid == uuid);
    if (index == -1) {
      return null;
    }
    return this.musicList[index];
  }

  ///设置播放模式
  void setPlayMode(PlayMode mode) {
    this.mode = mode;
    _callSave();
  }

  ///返回当前的播放列表
  MusicEntity? getCurrentMusicEntity() {
    if (musicList.isEmpty) {
      return null;
    }
    return currentMusic;
  }

  ///设置当前的播放音乐
  int setCurrentMusic(MusicEntity entity) {
    int index =
        this.musicList.indexWhere((element) => element.uuid == entity.uuid);
    if (index == -1) {
      return -1;
    }
    this.currentIndex = index;
    this.currentMusic = this.musicList[index];
    return this.currentIndex;
  }

  ///保存到本地数据
  void setSaveFun(VoidCallback callback) {
    this._save = callback;
  }

  ///偏移下一首
  bool _toNext() {
    if (currentIndex + 1 >= musicList.length) {
      return false;
    }
    currentIndex++;
    this.currentMusic = this.musicList[currentIndex];
    _callSave();
    return true;
  }

  ///偏移上一首
  bool _toPrevious() {
    if (currentIndex - 1 < 0) {
      return false;
    }
    currentIndex--;
    this.currentMusic = this.musicList[currentIndex];
    _callSave();
    return true;
  }

  ///切换下一首
  bool next() {
    if (currentIndex < 0) {
      currentIndex = 0;
      currentMusic = null;
      if (musicList.isNotEmpty) {
        currentMusic = musicList[currentIndex];
      }
    }
    switch (mode) {
      case PlayMode.loop:
        return true;
      case PlayMode.order:
        if (musicList.isEmpty) {
          return false;
        }
        if (!_toNext()) {
          return false;
        }
        return true;
      case PlayMode.random:
        if (_random == null) {
          _random = Random();
        }
        this.currentIndex = _random!.nextInt(musicList.length);
        this.currentMusic = this.musicList[currentIndex];
        return true;
      default:
        return false;
    }
  }

  ///切换上一首
  bool previous() {
    var state = _toPrevious();
    if (!state && mode == PlayMode.random) {
      currentIndex = 0;
      this.currentMusic = this.musicList[currentIndex];
    }
    return state;
  }

  ///是否有下一首
  bool hasPrevious() {
    if (currentIndex - 1 < 0) {
      return false;
    }
    return true;
  }

  ///是否有上一首
  bool hasNext() {
    if (currentIndex + 1 >= musicList.length) {
      return false;
    }
    return true;
  }

  void _callSave() {
    if (_save != null) {
      this._save!();
    }
  }

  ///调整顺序到指定位置
  bool toPositionIndex(int index) {
    if (index < 0 || index >= musicList.length) {
      return false;
    }
    currentIndex = index;
    this.currentMusic = this.musicList[currentIndex];
    _callSave();
    return true;
  }

  ///调整顺序到指定位置
  bool toPosition(MusicEntity entity) {
    var index =
        this.musicList.indexWhere((element) => element.uuid == entity.uuid);
    if (index == -1) {
      return false;
    }
    return toPositionIndex(index);
  }

  ///插入音乐
  void addMusic(MusicEntity entity) {
    this.musicList.add(entity);
    _checkData(entity);
    _callSave();
  }

  ///插入音乐
  void addMusicAll(List<MusicEntity> entityList) {
    entityList.forEach((element) => _checkData(element));
    this.musicList.addAll(entityList);
    _callSave();
  }

  ///根据下标移除音乐
  void removeAt(int index) {
    this.musicList.removeAt(index);
    if (currentIndex > index) {
      currentIndex--;
      currentMusic = musicList[currentIndex];
    }
    if (currentIndex > this.musicList.length) {
      currentIndex = this.musicList.length - 1;
      currentMusic = musicList[currentIndex];
    }
    _callSave();
  }

  ///根据下标移除音乐
  void removeByUuid(String uuid) {
    var index = this.musicList.indexWhere((element) => element.uuid == uuid);
    if (index != -1) {
      this.removeAt(index);
    }
  }

  ///根据对象移除音乐
  void remove(MusicEntity entity) {
    removeByUuid(entity.uuid!);
  }

  ///移动音乐到指定位置
  void moveIndex(int oldIndex, int newIndex) {
    var oldItem = this.musicList[oldIndex];
    this.musicList.removeAt(oldIndex);
    this.musicList.insert(newIndex, oldItem);
    if (oldIndex == currentIndex) {
      this.currentIndex = newIndex;
    }
    _callSave();
  }

  ///移动音乐到指定位置
  void moveAt(MusicEntity source, int index) {
    var i = this.musicList.indexWhere((element) => element.uuid == source.uuid);
    if (i == -1) {
      return;
    }
    moveIndex(i, index);
  }

  ///移动音乐到指定位置
  void move(MusicEntity source, MusicEntity target) {
    var i = this.musicList.indexWhere((element) => element.uuid == source.uuid);
    if (i == -1) {
      return;
    }
    var i2 =
        this.musicList.indexWhere((element) => element.uuid == target.uuid);
    if (i2 == -1) {
      return;
    }
    moveIndex(i, i2);
  }

  ///清空全部数据
  void clear() {
    this.musicList.clear();
    this.currentIndex = 0;
    this.currentMusic = null;
  }

  PlayListModel copyWith({
    List<MusicEntity>? musicList,
    PlayMode? mode,
    int? playIndex,
  }) {
    return PlayListModel(
      musicList: musicList ?? this.musicList,
      mode: mode ?? this.mode,
      currentIndex: playIndex ?? this.currentIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'musicList': musicList.map((x) => x.toMap()).toList(),
      'mode': EnumUtil.enumToString(mode),
      'playIndex': currentIndex,
    };
  }

  factory PlayListModel.fromMap(Map<String, dynamic> map) {
    return PlayListModel(
      musicList: List<MusicEntity>.from(
          map['musicList']?.map((x) => MusicEntity.fromMap(x))),
      mode: EnumUtil.enumFromString(PlayMode.values, map['mode'])!,
      currentIndex: map['playIndex'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayListModel.fromJson(String source) =>
      PlayListModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'PlayerListModel(musicList: $musicList, mode: $mode, playIndex: $currentIndex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayListModel &&
        listEquals(other.musicList, musicList) &&
        other.mode == mode &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode =>
      musicList.hashCode ^ mode.hashCode ^ currentIndex.hashCode;
}
