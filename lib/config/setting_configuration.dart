/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-07 23:53:41
 * @LastEditTime: 2021-07-07 23:57:11
 */
import 'package:xy_music_mobile/common/source_constant.dart';

///用户自定义设置配置
class SettingsConfiguration {
  static void configureMusicParseRoute(PlayUrlParseRoutesEnum route) {}

  ///获取音乐解析路线配置
  static PlayUrlParseRoutesEnum getConfigureMusicParseRoute() {
    return PlayUrlParseRoutesEnum.STABLE;
  }
}
