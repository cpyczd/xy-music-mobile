import 'dart:convert';

import '../util/orm/orm_base_model.dart';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 10:43:28
 * @LastEditTime: 2021-06-01 13:54:01
 */
///歌单数据
class SongGroup extends OrmBaseModel {
  final String groupName;

  String? coverImage;

  DateTime? createTime;

  DateTime? updateTime;

  SongGroup({
    int? id,
    required this.groupName,
    this.coverImage,
    this.createTime,
    this.updateTime,
  }) {
    super.id = id;
  }

  SongGroup copyWith({
    int? id,
    String? groupName,
    String? coverImage,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return SongGroup(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      coverImage: coverImage ?? this.coverImage,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupName': groupName,
      'coverImage': coverImage,
      'createTime': createTime?.millisecondsSinceEpoch,
      'updateTime': updateTime?.millisecondsSinceEpoch,
    };
  }

  factory SongGroup.fromMap(Map<String, dynamic> map) {
    return SongGroup(
      id: map['id'],
      groupName: map['groupName'],
      coverImage: map['coverImage'],
      createTime: DateTime.fromMillisecondsSinceEpoch(map['createTime']),
      updateTime: DateTime.fromMillisecondsSinceEpoch(map['updateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SongGroup.fromJson(String source) =>
      SongGroup.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongGroup(id: $id, groupName: $groupName, coverImage: $coverImage, createTime: $createTime, updateTime: $updateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongGroup &&
        other.id == id &&
        other.groupName == groupName &&
        other.coverImage == coverImage &&
        other.createTime == createTime &&
        other.updateTime == updateTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        groupName.hashCode ^
        coverImage.hashCode ^
        createTime.hashCode ^
        updateTime.hashCode;
  }
}

///歌单分组和歌曲关联表
class SongGoupLink extends OrmBaseModel {
  final int groupId;

  final int songId;

  DateTime? createTime;
  SongGoupLink({
    int? id,
    required this.groupId,
    required this.songId,
    this.createTime,
  }) {
    super.id = id;
  }

  SongGoupLink copyWith({
    int? id,
    int? groupId,
    int? songId,
    DateTime? createTime,
  }) {
    return SongGoupLink(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      songId: songId ?? this.songId,
      createTime: createTime ?? this.createTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'songId': songId,
      'createTime': createTime?.millisecondsSinceEpoch,
    };
  }

  factory SongGoupLink.fromMap(Map<String, dynamic> map) {
    return SongGoupLink(
      id: map['id'],
      groupId: map['groupId'],
      songId: map['songId'],
      createTime: DateTime.fromMillisecondsSinceEpoch(map['createTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SongGoupLink.fromJson(String source) =>
      SongGoupLink.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongGoupLink(id: $id, groupId: $groupId, songId: $songId, createTime: $createTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongGoupLink &&
        other.id == id &&
        other.groupId == groupId &&
        other.songId == songId &&
        other.createTime == createTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        groupId.hashCode ^
        songId.hashCode ^
        createTime.hashCode;
  }
}
