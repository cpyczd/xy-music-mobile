/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:07:50
 * @LastEditTime: 2021-06-16 10:56:00
 */

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'hot_page.dart';
import 'my_music_page.dart';
import 'setting_page.dart';
import 'song_square_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, MultDataLine {
  int _currentIndex = 0;

  final String _keyPageView = "PageViewKey";

  //上次点击时间
  DateTime? _lastPressedAt;

  @override
  void dispose() {
    disposeDataLine();
    //关闭Hive存储
    Hive.close();
    super.dispose();
  }

  ///创建ViewPage页面对象
  /// 主页曲库（搜索）推荐歌单、排行榜、我的曲库、设置
  List<Widget> _getPageViewWidget() {
    List<Widget> list = [
      SongSquarePage(),
      HotPage(),
      MyMusicPage(),
      SettingPage()
    ];
    return list;
  }

  @override
  void initState() {
    super.initState();
  }

  ///页面改变时间
  void _change(index) {
    setState(() {
      _currentIndex = index;
    });
    getLine(_keyPageView).inner.add(index);
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _change(index);
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
              icon: Icon(Icons.my_library_add), label: "我的曲库"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置")
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt!) >
                  Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            _lastPressedAt = DateTime.now();
            ToastUtil.show(msg: "再按一次退出程序");
            return false;
          }
          return true;
        },
        child: getLine(_keyPageView, initData: _currentIndex)
            .addObserver((context, data) => IndexedStack(
                  children: _getPageViewWidget(),
                  index: data,
                )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
