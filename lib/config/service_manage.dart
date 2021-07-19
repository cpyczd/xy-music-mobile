/*
 * @Description: 容器服务
 * @Author: chenzedeng
 * @Date: 2021-06-13 22:39:44
 * @LastEditTime: 2021-06-18 23:27:39
 */

import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import 'package:rxdart/rxdart.dart';

class BaseServiceProviderManage<T extends BaseCommon> {
  final List<T> _providers = [];

  ///注册提供者
  void register(T service) {
    _providers.add(service);
  }

  ///返回支持的提供者
  List<T> getSupportProvider(MusicSourceConstant source, {Object? fliter}) {
    return _providers
        .where((element) => element.support(source, fliter: fliter))
        .toList();
  }

  ///返回所支持的源
  List<MusicSourceConstant?> getSupportSourceList() {
    return _providers.map((e) => e.supportSource()).toList();
  }

  List<T> getSupportProviderAll(List<MusicSourceConstant> sources,
      {Object? fliter}) {
    return Stream.fromIterable(
            sources.map((e) => getSupportProvider(e)).toList())
        .flatMap((value) => Stream.fromIterable(value))
        .toList() as List<T>;
  }

  List<T> getProviderAll() {
    return List.from(_providers);
  }
}

///音乐解析管理
final musicServiceProviderMange = BaseServiceProviderManage<BaseMusicService>();

///歌单管理
final squareServiceProviderMange =
    BaseServiceProviderManage<BaseSongSquareService>();

///排行榜服务管理
final songRankingServiceProviderMange =
    BaseServiceProviderManage<BaseSongRankingService>();
