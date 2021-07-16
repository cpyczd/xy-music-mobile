/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-16 21:55:48
 * @LastEditTime: 2021-07-16 21:55:48
 */

import 'package:flutter/foundation.dart';

enum GroupEventEnum {
  ///音乐列表发送删除或者添加事件的改变
  MUSIC_LIST_CHANGE
}

extension GroupEventEnumPlus on GroupEventEnum {
  String get name => describeEnum(this);
}
