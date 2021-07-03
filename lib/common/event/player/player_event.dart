/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 20:57:41
 * @LastEditTime: 2021-07-03 23:02:38
 */

import 'package:xy_music_mobile/common/event/player/player_base_event.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/model/music_entity.dart';

///播放进度改变事件
class PlayerPositionChangedEvent extends PlayerBaseEvent {
  final Duration duration;

  PlayerPositionChangedEvent(this.duration, MusicEntity musicEntity)
      : super(musicEntity);
}

///播放出现异常事件
class PlayerErrorEvent extends PlayerBaseEvent {
  final String msg;

  PlayerErrorEvent(this.msg, MusicEntity musicEntity) : super(musicEntity);
}

///播放事件改变
class PlayerChangeEvent extends PlayerBaseEvent {
  final PlayStatus state;

  PlayerChangeEvent(this.state, musicEntity) : super(musicEntity);
}
