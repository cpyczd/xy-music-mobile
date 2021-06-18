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
import 'package:xy_music_mobile/pages/square/square_info_page.dart';
import 'package:xy_music_mobile/pages/square/square_list_page.dart';
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

///歌单列表页面
Handler squareListPage = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
  return SquareListPage();
});

///歌单歌曲详情页面
Handler squareInfoPage = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
  return SquareInfoPage();
});
