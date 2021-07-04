import 'dart:convert';

import 'package:flutter/foundation.dart';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-14 13:52:34
 * @LastEditTime: 2021-06-16 15:09:40
 */

import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/util/index.dart';

///标签
class SongSqurareTag {
  final MusicSourceConstant source;

  final String name;

  List<SongSqurareTagItem>? tags;
  SongSqurareTag({
    required this.source,
    required this.name,
    this.tags,
  });

  SongSqurareTag copyWith({
    MusicSourceConstant? source,
    String? name,
    List<SongSqurareTagItem>? tags,
  }) {
    return SongSqurareTag(
      source: source ?? this.source,
      name: name ?? this.name,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source.name,
      'name': name,
      'tags': tags?.toList(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'SongSqurareTag(source: $source, name: $name, tags: $tags)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongSqurareTag &&
        other.source == source &&
        other.name == name &&
        listEquals(other.tags, tags);
  }

  @override
  int get hashCode => source.hashCode ^ name.hashCode ^ tags.hashCode;
}

///Tag 标签数据实体类
class SongSqurareTagItem {
  final String name;

  final String parentName;

  final String id;

  final String parentId;
  SongSqurareTagItem({
    required this.name,
    required this.parentName,
    required this.id,
    required this.parentId,
  });

  SongSqurareTagItem copyWith({
    String? name,
    String? parentName,
    String? id,
    String? parentId,
  }) {
    return SongSqurareTagItem(
      name: name ?? this.name,
      parentName: parentName ?? this.parentName,
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parentName': parentName,
      'id': id,
      'parentId': parentId,
    };
  }

  factory SongSqurareTagItem.fromMap(Map<String, dynamic> map) {
    return SongSqurareTagItem(
      name: map['name'],
      parentName: map['parentName'],
      id: map['id'],
      parentId: map['parentId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SongSqurareTagItem.fromJson(String source) =>
      SongSqurareTagItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongSqurareTagItem(name: $name, parentName: $parentName, id: $id, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongSqurareTagItem &&
        other.name == name &&
        other.parentName == parentName &&
        other.id == id &&
        other.parentId == parentId;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        parentName.hashCode ^
        id.hashCode ^
        parentId.hashCode;
  }
}

///歌单信息
class SongSquareInfo {
  ///specialid
  final String id;

  ///播放次数
  final String playCount;

  ///收藏数量
  String? collectCount;

  ///歌单名称
  final String name;

  ///时间
  final String time;

  ///图片
  final String img;

  ///评分
  double? grade;

  ///描述
  String? desc;

  ///作者
  final String author;

  Map? original;
  SongSquareInfo({
    required this.id,
    required this.playCount,
    this.collectCount,
    required this.name,
    required this.time,
    required this.img,
    this.grade,
    this.desc,
    required this.author,
    this.original,
  });

  SongSquareInfo copyWith({
    String? id,
    String? playCount,
    String? collectCount,
    String? name,
    String? time,
    String? img,
    double? grade,
    String? desc,
    String? author,
    Map? original,
  }) {
    return SongSquareInfo(
      id: id ?? this.id,
      playCount: playCount ?? this.playCount,
      collectCount: collectCount ?? this.collectCount,
      name: name ?? this.name,
      time: time ?? this.time,
      img: img ?? this.img,
      grade: grade ?? this.grade,
      desc: desc ?? this.desc,
      author: author ?? this.author,
      original: original ?? this.original,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playCount': playCount,
      'collectCount': collectCount,
      'name': name,
      'time': time,
      'img': img,
      'grade': grade,
      'desc': desc,
      'author': author,
      'original': original,
    };
  }

  factory SongSquareInfo.fromMap(Map<String, dynamic> map) {
    return SongSquareInfo(
      id: map['id'],
      playCount: map['playCount'],
      collectCount: map['collectCount'],
      name: map['name'],
      time: map['time'],
      img: map['img'],
      grade: map['grade'],
      desc: map['desc'],
      author: map['author'],
      original: map['original'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SongSquareInfo.fromJson(String source) =>
      SongSquareInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongSquareInfo(id: $id, playCount: $playCount, collectCount: $collectCount, name: $name, time: $time, img: $img, grade: $grade, desc: $desc, author: $author, original: $original)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongSquareInfo &&
        other.id == id &&
        other.playCount == playCount &&
        other.collectCount == collectCount &&
        other.name == name &&
        other.time == time &&
        other.img == img &&
        other.grade == grade &&
        other.desc == desc &&
        other.author == author &&
        other.original == original;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        playCount.hashCode ^
        collectCount.hashCode ^
        name.hashCode ^
        time.hashCode ^
        img.hashCode ^
        grade.hashCode ^
        desc.hashCode ^
        author.hashCode ^
        original.hashCode;
  }
}

///类别
class SongSquareSort {
  final String name;
  final String id;

  SongSquareSort({
    required this.name,
    required this.id,
  });

  SongSquareSort copyWith({
    String? name,
    String? id,
  }) {
    return SongSquareSort(
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
    };
  }

  factory SongSquareSort.fromMap(Map<String, dynamic> map) {
    return SongSquareSort(
      name: map['name'],
      id: map['id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SongSquareSort.fromJson(String source) =>
      SongSquareSort.fromMap(json.decode(source));

  @override
  String toString() => 'SongSquareSort(name: $name, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongSquareSort && other.name == name && other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ id.hashCode;
}

///歌单内音乐
class SongSquareMusic {
  final String id;

  ///歌名
  final String songName;

  ///歌手
  final String singer;

  ///专辑
  final String album;

  ///原始数据
  final Map originalData;

  ///时长
  Duration? duration;

  ///时长字符串
  String? durationStr;

  ///源
  final MusicSourceConstant source;
  SongSquareMusic({
    required this.id,
    required this.songName,
    required this.singer,
    required this.album,
    required this.originalData,
    this.duration,
    this.durationStr,
    required this.source,
  });

  SongSquareMusic copyWith({
    String? id,
    String? songName,
    String? singer,
    String? album,
    Map? originalData,
    Duration? duration,
    String? durationStr,
    MusicSourceConstant? source,
  }) {
    return SongSquareMusic(
      id: id ?? this.id,
      songName: songName ?? this.songName,
      singer: singer ?? this.singer,
      album: album ?? this.album,
      originalData: originalData ?? this.originalData,
      duration: duration ?? this.duration,
      durationStr: durationStr ?? this.durationStr,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songName': songName,
      'singer': singer,
      'album': album,
      'originalData': originalData,
      'duration': duration,
      'durationStr': durationStr,
      'source': source.name,
    };
  }

  factory SongSquareMusic.fromMap(Map<String, dynamic> map) {
    return SongSquareMusic(
      id: map['id'],
      songName: map['songName'],
      singer: map['singer'],
      album: map['album'],
      originalData: Map.from(map['originalData']),
      duration: map['duration'],
      durationStr: map['durationStr'],
      source: EnumUtil.enumFromString<MusicSourceConstant>(
          MusicSourceConstant.values, map["source"])!,
    );
  }

  String toJson() => json.encode(toMap());

  factory SongSquareMusic.fromJson(String source) =>
      SongSquareMusic.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongSquareMusic(id: $id, songName: $songName, singer: $singer, album: $album, originalData: $originalData, duration: $duration, durationStr: $durationStr, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongSquareMusic &&
        other.id == id &&
        other.songName == songName &&
        other.singer == singer &&
        other.album == album &&
        mapEquals(other.originalData, originalData) &&
        other.duration == duration &&
        other.durationStr == durationStr &&
        other.source == source;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        songName.hashCode ^
        singer.hashCode ^
        album.hashCode ^
        originalData.hashCode ^
        duration.hashCode ^
        durationStr.hashCode ^
        source.hashCode;
  }
}
