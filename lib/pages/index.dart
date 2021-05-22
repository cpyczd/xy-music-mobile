/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:07:50
 * @LastEditTime: 2021-05-22 16:41:15
 */

import 'package:flutter/material.dart';
import 'hot_page.dart';
import 'my_music_page.dart';
import 'search_page.dart';
import 'setting_page.dart';
import 'song_square_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  int _currentIndex = 0;

  ///创建ViewPage页面对象
  List<Widget> _getPageViewWidget() {
    List<Widget> list = [
      SongSquarePage(),
      HotPage(),
      MyMusicPage(),
      SearchPage(),
      SettingPage()
    ];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w200),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.music_note_outlined), label: "歌单广场"),
          BottomNavigationBarItem(icon: Icon(Icons.hot_tub), label: "排行榜"),
          BottomNavigationBarItem(
              icon: Icon(Icons.my_library_add), label: "我的"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "搜索"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置")
        ],
      ),
      body: IndexedStack(
        children: _getPageViewWidget(),
        index: _currentIndex,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
