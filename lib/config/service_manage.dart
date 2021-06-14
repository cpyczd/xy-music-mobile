/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-13 22:39:44
 * @LastEditTime: 2021-06-14 21:10:05
 */

import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/service/music_service.dart';

class MusicServiceProviderMange {
  static final List<MusicService> _providers = [];

  ///注册提供者
  static void register(MusicService service) {
    _providers.add(service);
  }

  ///返回支持的提供者
  static List<MusicService> getSupportProvider(MusicSourceConstant type,
      {Object? fliter}) {
    return _providers
        .where((element) => element.support(type, fliter))
        .toList();
  }

  ///返回所有的提供者对象
  static List<MusicService> getProviderAll() {
    return List.from(_providers);
  }
}

class SquareServiceProviderMange {
  static final List<SongSquareService> _providers = [];

  ///注册提供者
  static void register(SongSquareService service) {
    _providers.add(service);
  }

  ///返回支持的提供者
  static List<SongSquareService> getSupportProvider(MusicSourceConstant type,
      {Object? fliter}) {
    return _providers
        .where((element) => element.support(type, fliter))
        .toList();
  }

  ///返回所有的提供者对象
  static List<SongSquareService> getProviderAll() {
    return List.from(_providers);
  }
}
