/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-11 22:15:51
 * @LastEditTime: 2021-07-11 22:22:05
 */

import 'package:xy_music_mobile/util/orm/orm.dart';

///数据库配置
///历史版本
///Version:
///* 1 ->Current

///当前版本
const int CURRENT_VERSION = 1;

///数据库名称
const String CURRENT_DATABASE_NAME = "xy-music-mobile-database.db";

///在[Applitation]里进行初始化
void initDataBase() {
  OrmHelper.setDataBaseName(CURRENT_DATABASE_NAME);
  OrmHelper.setDataBaseVersion(CURRENT_VERSION);
}
