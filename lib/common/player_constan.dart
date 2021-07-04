/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 17:42:59
 * @LastEditTime: 2021-07-03 15:28:01
 */
import 'package:flutter/foundation.dart';

///播放状态
enum PlayStatus { paused, playing, stop, loading, ready, error, completed }

///播放模式
enum PlayMode { order, random, loop }

///播放列表改变事件
enum PlayListChangeState { add, delete }

extension PlayModeExtension on PlayMode {
  String get name => describeEnum(this);

  String get desc {
    switch (this) {
      case PlayMode.order:
        return "顺序播放";
      case PlayMode.random:
        return "随机播放";
      case PlayMode.loop:
        return "单曲循环";
      default:
        return "NONE";
    }
  }
}
