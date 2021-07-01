import 'dart:convert';

import 'package:flutter/foundation.dart';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 17:40:45
 * @LastEditTime: 2021-07-01 18:20:39
 */
import 'package:xy_music_mobile/common/player_constan.dart';
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

  PlayerListModel({
    required this.musicList,
    this.mode = PlayMode.order,
    this.playIndex = 0,
  });

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
      'musicList': musicList?.map((x) => x.toMap())?.toList(),
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
