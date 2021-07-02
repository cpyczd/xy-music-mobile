import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 17:40:45
 * @LastEditTime: 2021-07-02 23:31:56
 */
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/util/index.dart';

import 'music_entity.dart';

///当前音乐播放列表
class PlayerListModel {
  //播放列表
  List<MusicEntity> musicList;

  //播放模式
  PlayMode mode;

  ///播放的歌曲下标
  int playIndex;

  Random? _random;

  VoidCallback? _save;

  var _uuid = Uuid();

  PlayerListModel({
    required this.musicList,
    this.mode = PlayMode.order,
    this.playIndex = 0,
  }) {
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

  ///返回当前的播放列表
  MusicEntity getCurrentMusicEntity() {
    if (playIndex > musicList.length) {
      throw new Exception("playe index out");
    }
    return musicList[playIndex];
  }

  ///设置当前的播放音乐
  int setCurrentMusic(MusicEntity entity) {
    this.playIndex = this.musicList.indexOf(entity);
    return this.playIndex;
  }

  ///保存到本地数据
  void setSaveFun(VoidCallback callback) {
    this._save = callback;
  }

  ///偏移下一首
  bool _toNext() {
    if (playIndex + 1 >= musicList.length) {
      return false;
    }
    playIndex++;
    return true;
  }

  ///偏移上一首
  bool _toPrevious() {
    if (playIndex - 1 < 0) {
      return false;
    }
    playIndex--;
    return true;
  }

  ///切换下一首
  bool next() {
    switch (mode) {
      case PlayMode.loop:
        return true;
      case PlayMode.order:
        if (musicList.isEmpty) {
          return false;
        }
        if (!_toNext()) {
          playIndex = 0;
        }
        return true;
      case PlayMode.random:
        if (_random == null) {
          _random = Random();
        }
        this.playIndex = _random!.nextInt(musicList.length);
        return true;
      default:
        return false;
    }
  }

  ///切换上一首
  bool previous() {
    var state = _toPrevious();
    if (!state && mode == PlayMode.random) {
      playIndex = 0;
    }
    return state;
  }

  ///是否有下一首
  bool hasPrevious() {
    if (playIndex - 1 < 0) {
      return false;
    }
    return true;
  }

  ///是否有上一首
  bool hasNext() {
    if (playIndex + 1 >= musicList.length) {
      return false;
    }
    return true;
  }

  void _callSave() {
    if (_save != null) {
      this._save!();
    }
  }

  ///插入音乐
  void addMusic(MusicEntity entity) {
    this.musicList.insert(0, entity);
    _checkData(entity);
    _callSave();
  }

  ///插入音乐
  void addMusicAll(List<MusicEntity> entityList) {
    entityList.forEach((element) => _checkData(element));
    this.musicList.insertAll(0, entityList);
    _callSave();
  }

  ///根据下标移除音乐
  void removeAt(int index) {
    this.musicList.removeAt(index);
    if (playIndex >= this.musicList.length) {
      playIndex = this.musicList.length - 1;
    }
    _callSave();
  }

  ///根据对象移除音乐
  void remove(MusicEntity entity) {
    this.musicList.remove(entity);
    if (playIndex >= this.musicList.length) {
      playIndex = this.musicList.length - 1;
    }
    _callSave();
  }

  ///移动音乐到指定位置
  void moveAt(MusicEntity source, int index) {
    this.musicList.remove(source);
    this.musicList.insert(index, source);
    _callSave();
  }

  ///移动音乐到指定位置
  void move(MusicEntity source, MusicEntity target) {
    this.musicList.remove(source);
    this.musicList.insert(this.musicList.indexOf(target), source);
    _callSave();
  }

  PlayerListModel copyWith({
    List<MusicEntity>? musicList,
    PlayMode? mode,
    int? playIndex,
  }) {
    return PlayerListModel(
      musicList: musicList ?? this.musicList,
      mode: mode ?? this.mode,
      playIndex: playIndex ?? this.playIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'musicList': musicList.map((x) => x.toMap()).toList(),
      'mode': EnumUtil.enumToString(mode),
      'playIndex': playIndex,
    };
  }

  factory PlayerListModel.fromMap(Map<String, dynamic> map) {
    return PlayerListModel(
      musicList: List<MusicEntity>.from(
          map['musicList']?.map((x) => MusicEntity.fromMap(x))),
      mode: EnumUtil.enumFromString(PlayMode.values, map['mode'])!,
      playIndex: map['playIndex'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerListModel.fromJson(String source) =>
      PlayerListModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'PlayerListModel(musicList: $musicList, mode: $mode, playIndex: $playIndex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerListModel &&
        listEquals(other.musicList, musicList) &&
        other.mode == mode &&
        other.playIndex == playIndex;
  }

  @override
  int get hashCode => musicList.hashCode ^ mode.hashCode ^ playIndex.hashCode;
}
