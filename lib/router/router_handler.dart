/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-05-22 16:44:45
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/pages/player_page.dart';
import 'package:xy_music_mobile/pages/search_page.dart';
import '/pages/index.dart';

///Home Page
Handler homePage = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
  return HomePage();
});

///搜索页面
Handler searchPage = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
  return SearchPage();
});

///播放界面
Handler playerPage = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
  return PlayerPage();
});
