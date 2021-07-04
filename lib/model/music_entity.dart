import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:xy_music_mobile/model/base_entity.dart';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 13:26:03
 * @LastEditTime: 2021-07-04 20:50:59
 */

import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/util/index.dart';

///音乐模块实体类
class MusicEntity extends BaseEntity {
  String? uuid;

  ///歌曲ID
  final String? songmId;

  ///专辑ID
  final String? albumId;

  ///专辑名称
  final String? albumName;

  ///歌手
  final String? singer;

  ///歌名
  final String songName;

  ///原始歌名
  final String? songnameOriginal;

  ///来源 kg、wy等....
  MusicSourceConstant source;

  ///时长
  final Duration duration;

  ///时长字符串
  String? durationStr;

  ///图片封面
  String? picImage;

  ///歌词
  String? lrc;

  ///Hash
  String? hash;

  ///音质
  String? quality;

  ///音质文件大小
  int? qualityFileSize;

  List<String>? types;

  ///音乐播放地址
  String? playUrl;

  final Map originData;

  MusicEntity(
      {int? id,
      this.songmId,
      this.albumId,
      this.albumName,
      this.singer,
      this.playUrl,
      required this.songName,
      this.songnameOriginal,
      required this.source,
      required this.duration,
      this.durationStr,
      this.picImage,
      this.lrc,
      this.hash,
      this.quality,
      this.qualityFileSize,
      this.types,
      required this.originData,
      this.uuid}) {
    super.id = id;
  }

  MusicEntity copyWith({
    int? id,
    String? songmId,
    String? albumId,
    String? albumName,
    String? singer,
    String? playUrl,
    String? songName,
    String? songnameOriginal,
    MusicSourceConstant? source,
    Duration? duration,
    String? durationStr,
    String? picImage,
    String? lrc,
    String? hash,
    String? quality,
    int? qualityFileSize,
    List<String>? types,
    Map<String, dynamic>? originData,
  }) {
    return MusicEntity(
      id: id ?? this.id,
      songmId: songmId ?? this.songmId,
      playUrl: playUrl ?? this.playUrl,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      singer: singer ?? this.singer,
      songName: songName ?? this.songName,
      songnameOriginal: songnameOriginal ?? this.songnameOriginal,
      source: source ?? this.source,
      duration: duration ?? this.duration,
      durationStr: durationStr ?? this.durationStr,
      picImage: picImage ?? this.picImage,
      lrc: lrc ?? this.lrc,
      hash: hash ?? this.hash,
      quality: quality ?? this.quality,
      qualityFileSize: qualityFileSize ?? this.qualityFileSize,
      types: types ?? this.types,
      originData: originData ?? this.originData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playUrl': playUrl,
      'songmId': songmId,
      'albumId': albumId,
      'albumName': albumName,
      'singer': singer,
      'songName': songName,
      'songnameOriginal': songnameOriginal,
      'source': source.name,
      'duration': duration.inMilliseconds,
      'durationStr': durationStr,
      'picImage': picImage,
      'lrc': lrc,
      'hash': hash,
      'quality': quality,
      'qualityFileSize': qualityFileSize,
      'types': types != null ? jsonEncode(types) : null,
      'originData': jsonEncode(originData),
      'uuid': uuid
    };
  }

  factory MusicEntity.fromMap(Map<String, dynamic> map) {
    return MusicEntity(
        id: map['id'],
        songmId: map['songmId'],
        albumId: map['albumId'],
        albumName: map['albumName'],
        singer: map['singer'],
        songName: map['songName'],
        songnameOriginal: map['songnameOriginal'],
        source:
            EnumUtil.enumFromString(MusicSourceConstant.values, map['source'])!,
        duration: Duration(milliseconds: map['duration']),
        durationStr: map['durationStr'],
        picImage: map['picImage'],
        lrc: map['lrc'],
        hash: map['hash'],
        playUrl: map['playUrl'],
        quality: map['quality'],
        qualityFileSize: map['qualityFileSize'],
        types: StringUtils.isNotBlank(map['types'])
            ? List<String>.from(jsonDecode(map['types']))
            : null,
        originData: StringUtils.isNotBlank(map['originData'])
            ? Map<String, dynamic>.from(jsonDecode(map['originData']))
            : {},
        uuid: map["uuid"]);
  }

  String toJson() => json.encode(toMap());

  factory MusicEntity.fromJson(String source) =>
      MusicEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MusicEntity(id: $id,uuid: $uuid songmId: $songmId, albumId: $albumId, albumName: $albumName, singer: $singer, songName: $songName, songnameOriginal: $songnameOriginal, source: $source, duration: $duration, durationStr: $durationStr, picImage: $picImage, lrc: $lrc, hash: $hash, quality: $quality, qualityFileSize: $qualityFileSize, types: $types, playUrl: $playUrl, originData: $originData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MusicEntity &&
        other.id == id &&
        other.songmId == songmId &&
        other.albumId == albumId &&
        other.albumName == albumName &&
        other.singer == singer &&
        other.songName == songName &&
        other.songnameOriginal == songnameOriginal &&
        other.source == source &&
        other.duration == duration &&
        other.durationStr == durationStr &&
        other.picImage == picImage &&
        other.lrc == lrc &&
        other.hash == hash &&
        other.quality == quality &&
        other.playUrl == playUrl &&
        other.qualityFileSize == qualityFileSize &&
        listEquals(other.types, types) &&
        mapEquals(other.originData, originData);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        songmId.hashCode ^
        albumId.hashCode ^
        albumName.hashCode ^
        singer.hashCode ^
        songName.hashCode ^
        songnameOriginal.hashCode ^
        source.hashCode ^
        duration.hashCode ^
        durationStr.hashCode ^
        picImage.hashCode ^
        lrc.hashCode ^
        hash.hashCode ^
        quality.hashCode ^
        qualityFileSize.hashCode ^
        types.hashCode ^
        playUrl.hashCode ^
        originData.hashCode;
  }
}
