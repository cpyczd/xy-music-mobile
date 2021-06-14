/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-14 12:19:08
 * @LastEditTime: 2021-06-14 12:48:17
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

void register() {
  ThemeConfig.registers(themes);
}
