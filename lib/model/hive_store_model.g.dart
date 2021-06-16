// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_store_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveStoreModelAdapter extends TypeAdapter<HiveStoreModel> {
  @override
  final int typeId = 0;

  @override
  HiveStoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveStoreModel(
      json: fields[0] as String,
      otherJson: fields[1] as String?,
      createTime: fields[2] as int,
      updateTime: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveStoreModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.json)
      ..writeByte(1)
      ..write(obj.otherJson)
      ..writeByte(2)
      ..write(obj.createTime)
      ..writeByte(3)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveStoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
