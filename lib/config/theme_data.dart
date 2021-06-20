/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-14 12:19:08
 * @LastEditTime: 2021-06-20 22:40:37
 */

import './theme.dart';

final themes = [
  MaterialColor(
      themeName: "default",
      primaryColor: 0xFF03A9F4,
      primaryColorLight: 0xFFB3E5FC,
      scaffoldBackgroundColor: 0xFFfafafa),
  MaterialColor(
      themeName: "read",
      primaryColor: 0xFF03A9F4,
      primaryColorLight: 0xFFB3E5FC,
      scaffoldBackgroundColor: 0xFFfafafa)
];

///注册服务方法、调用交给Application类去管理
void register() {
  ThemeConfig.registers(themes);
}
