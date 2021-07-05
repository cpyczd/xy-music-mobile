import 'dart:convert';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 20:59:28
 * @LastEditTime: 2021-07-05 20:36:01
 */
import 'package:xy_music_mobile/model/music_entity.dart';

class PlayerBaseEvent {
  final MusicEntity? musicEntity;

  PlayerBaseEvent(
    this.musicEntity,
  );
}
