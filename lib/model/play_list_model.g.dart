/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-05 14:18:20
 * @LastEditTime: 2021-07-05 15:46:45
 */
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayListModelAdapter extends TypeAdapter<PlayListModel> {
  @override
  final int typeId = 1;

  @override
  PlayListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayListModel(
      musicList: (json.decode(fields[0]) as List)
          .map((e) => MusicEntity.fromMap(e))
          .toList(),
      mode: EnumUtil.enumFromString(PlayMode.values, fields[1])!,
      currentIndex: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayListModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(json.encode(obj.musicList.map((e) => e.toMap()).toList()))
      ..writeByte(1)
      ..write(obj.mode.name)
      ..writeByte(2)
      ..write(obj.currentIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
