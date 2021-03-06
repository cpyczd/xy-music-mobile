/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 13:49:36
 * @LastEditTime: 2021-07-10 00:00:05
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

///播放源
enum MusicSourceConstant { kg, kw, tx, wy, mg, xm, none }

extension MusicSourceExtension on MusicSourceConstant {
  String get name => describeEnum(this);

  String get desc => originalDesc;

  String get aliasDesc {
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

  String get originalDesc {
    switch (this) {
      case MusicSourceConstant.kg:
        return '酷狗';
      case MusicSourceConstant.kw:
        return '酷我';
      case MusicSourceConstant.tx:
        return 'QQ';
      case MusicSourceConstant.wy:
        return '网易';
      case MusicSourceConstant.mg:
        return '咪咕';
      case MusicSourceConstant.xm:
        return '虾米';
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

///播放地址源解析路线
enum PlayUrlParseRoutesEnum {
  ///稳定的:代表全部如果有失败的继续下一个路由去请求直到成功或者没有路线可进行.
  STABLE,

  ///测试的 路线接口
  BETA,

  ///实验的 路线接口
  ALPHA
}

extension PlayUrlParseTypeEnumEnhance on PlayUrlParseRoutesEnum {
  String get name => describeEnum(this);
}
