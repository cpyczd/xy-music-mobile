/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 13:49:36
 * @LastEditTime: 2021-05-23 14:57:50
 * 
 * 
 * {
      name: '酷我音乐',
      id: 'kw',
    },
    {
      name: '酷狗音乐',
      id: 'kg',
    },
    {
      name: 'QQ音乐',
      id: 'tx',
    },
    {
      name: '网易音乐',
      id: 'wy',
    },
    {
      name: '咪咕音乐',
      id: 'mg',
    },
    {
      name: '虾米音乐',
      id: 'xm',
    },
 */

import 'package:flutter/foundation.dart';

enum MusicSourceConstant { kg, kw, tx, wy, mg, xm, none }

extension MusicSourceExtension on MusicSourceConstant {
  String get name => describeEnum(this);
  String get desc {
    switch (this) {
      case MusicSourceConstant.kg:
        return '小枸音乐';
      case MusicSourceConstant.kw:
        return '小蜗音乐';
      case MusicSourceConstant.tx:
        return '小秋音乐';
      case MusicSourceConstant.wy:
        return '小芸音乐';
      case MusicSourceConstant.mg:
        return '小密音乐';
      case MusicSourceConstant.xm:
        return '小夏音乐';
      default:
        return 'None';
    }
  }
}

///音质支持
class MusicSupportQualitys {
  static final List<String> kw = ['128k', '320k', 'flac'];
  static final List<String> kg = ['128k', '320k', 'flac'];
  static final List<String> tx = ['128k', '320k', 'flac'];
  static final List<String> wy = ['128k', '320k', 'flac'];
  static final List<String> mg = ['128k', '320k', 'flac'];
}
