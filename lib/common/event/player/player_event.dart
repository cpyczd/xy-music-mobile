/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 20:57:41
 * @LastEditTime: 2021-07-01 21:06:09
 */

import 'package:xy_music_mobile/common/event/player/player_base_event.dart';
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

///播放完成事件
class PlayerCompletionEvent extends PlayerBaseEvent {
  PlayerCompletionEvent(MusicEntity musicEntity) : super(musicEntity);
}
