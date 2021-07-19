import 'dart:convert';

import 'package:flutter/foundation.dart';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-16 14:37:49
 * @LastEditTime: 2021-07-04 17:55:55
 */

import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/util/index.dart';

///歌曲排行榜
class SongRankingListEntity {
  final String id;

  ///排行榜名称
  final String name;

  ///播放源
  final MusicSourceConstant source;

  ///其他数据、原始数据
  Map? original;

  ///歌曲Item List
  List<SongRankingListItemEntity>? songList;
  SongRankingListEntity({
    required this.id,
    required this.name,
    required this.source,
    this.original,
    this.songList,
  });

  SongRankingListEntity copyWith({
    String? id,
    String? name,
    MusicSourceConstant? source,
    Map? original,
    List<SongRankingListItemEntity>? songList,
  }) {
    return SongRankingListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      original: original ?? this.original,
      songList: songList ?? this.songList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'source': source.name,
      'original': original,
      'songList': songList?.map((x) => x.toMap()).toList(),
    };
  }

  factory SongRankingListEntity.fromMap(Map<String, dynamic> map) {
    return SongRankingListEntity(
      id: map['id'],
      name: map['name'],
      source: EnumUtil.enumFromString<MusicSourceConstant>(
          MusicSourceConstant.values, map["source"])!,
      original: map['original'],
      songList: List<SongRankingListItemEntity>.from(
          map['songList']?.map((x) => SongRankingListItemEntity.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory SongRankingListEntity.fromJson(String source) =>
      SongRankingListEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongRankingListEntity(id: $id, name: $name, source: $source, original: $original, songList: $songList)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongRankingListEntity &&
        other.id == id &&
        other.name == name &&
        other.source == source &&
        other.original == original &&
        listEquals(other.songList, songList);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        source.hashCode ^
        original.hashCode ^
        songList.hashCode;
  }
}

class SongRankingListItemEntity {
  ///ID
  final String id;

  ///歌名
  final String songName;

  ///歌手
  final String singer;

  ///专辑
  final String album;

  ///时长
  Duration? duration;

  ///时长字符串
  String? durationStr;

  ///源
  final MusicSourceConstant source;

  ///原始数据
  final Map originalData;
  SongRankingListItemEntity({
    required this.id,
    required this.songName,
    required this.singer,
    required this.album,
    this.duration,
    this.durationStr,
    required this.source,
    required this.originalData,
  });

  SongRankingListItemEntity copyWith({
    String? id,
    String? songName,
    String? singer,
    String? album,
    Duration? duration,
    String? durationStr,
    MusicSourceConstant? source,
    Map? originalData,
  }) {
    return SongRankingListItemEntity(
      id: id ?? this.id,
      songName: songName ?? this.songName,
      singer: singer ?? this.singer,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      durationStr: durationStr ?? this.durationStr,
      source: source ?? this.source,
      originalData: originalData ?? this.originalData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songName': songName,
      'singer': singer,
      'album': album,
      'duration': duration,
      'durationStr': durationStr,
      'source': source.name,
      'originalData': originalData,
    };
  }

  factory SongRankingListItemEntity.fromMap(Map<String, dynamic> map) {
    return SongRankingListItemEntity(
        id: map['id'],
        songName: map['songName'],
        singer: map['singer'],
        album: map['album'],
        duration: map['duration'],
        durationStr: map['durationStr'],
        originalData: Map.from(map['originalData']),
        source: EnumUtil.enumFromString<MusicSourceConstant>(
            MusicSourceConstant.values, map["source"])!);
  }

  String toJson() => json.encode(toMap());

  factory SongRankingListItemEntity.fromJson(String source) =>
      SongRankingListItemEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongRankingListItemEntity(id: $id, songName: $songName, singer: $singer, album: $album, duration: $duration, durationStr: $durationStr, source: $source, originalData: $originalData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongRankingListItemEntity &&
        other.id == id &&
        other.songName == songName &&
        other.singer == singer &&
        other.album == album &&
        other.duration == duration &&
        other.durationStr == durationStr &&
        other.source == source &&
        mapEquals(other.originalData, originalData);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        songName.hashCode ^
        singer.hashCode ^
        album.hashCode ^
        duration.hashCode ^
        durationStr.hashCode ^
        source.hashCode ^
        originalData.hashCode;
  }
}
