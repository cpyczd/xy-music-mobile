/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-16 10:23:59
 * @LastEditTime: 2021-06-16 10:36:48
 */
import 'package:hive/hive.dart';
import 'dart:convert' as convert;
part 'hive_store_model.g.dart';

@HiveType(typeId: 0)
class HiveStoreModel extends HiveObject {
  @HiveField(0)
  final String json;

  @HiveField(1)
  String? otherJson;

  @HiveField(2)
  final int createTime;

  @HiveField(3)
  final int updateTime;

  HiveStoreModel({
    required this.json,
    this.otherJson,
    required this.createTime,
    required this.updateTime,
  });

  HiveStoreModel copyWith({
    String? json,
    String? otherJson,
    int? createTime,
    int? updateTime,
  }) {
    return HiveStoreModel(
      json: json ?? this.json,
      otherJson: otherJson ?? this.otherJson,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'json': json,
      'otherJson': otherJson,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  factory HiveStoreModel.fromMap(Map<String, dynamic> map) {
    return HiveStoreModel(
      json: map['json'],
      otherJson: map['otherJson'],
      createTime: map['createTime'],
      updateTime: map['updateTime'],
    );
  }

  String toJson() => convert.json.encode(toMap());

  factory HiveStoreModel.fromJson(String source) =>
      HiveStoreModel.fromMap(convert.json.decode(source));

  @override
  String toString() {
    return 'HiveStoreModel(json: $json, otherJson: $otherJson, createTime: $createTime, updateTime: $updateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HiveStoreModel &&
        other.json == json &&
        other.otherJson == otherJson &&
        other.createTime == createTime &&
        other.updateTime == updateTime;
  }

  @override
  int get hashCode {
    return json.hashCode ^
        otherJson.hashCode ^
        createTime.hashCode ^
        updateTime.hashCode;
  }
}
