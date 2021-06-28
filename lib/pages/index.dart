/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:07:50
 * @LastEditTime: 2021-06-28 16:23:42
 */

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/theme.dart';
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
  int _currentIndex = 1;

  final String _keyPageView = "PageViewKey";

  //上次点击时间
  DateTime? _lastPressedAt;

  final TextStyle _selected = TextStyle(
      color: Color(AppTheme.getCurrentTheme().primaryColor),
      fontSize: 20,
      fontWeight: FontWeight.w500);

  final TextStyle _unselect = TextStyle(color: Colors.white, fontSize: 15);

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
      MyMusicPage(),
      SongSquarePage(),
      HotPage(),
      // SettingPage()
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
    getLine(_keyPageView).setData(index);
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: BottomNavigationBar(
      //   onTap: (index) {
      //     setState(() {
      //       _change(index);
      //     });
      //   },
      //   currentIndex: _currentIndex,
      //   selectedItemColor: Theme.of(context).primaryColor,
      //   unselectedItemColor: Colors.grey,
      //   selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      //   unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w200),
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.music_note_outlined), label: "歌单广场"),
      //     BottomNavigationBarItem(icon: Icon(Icons.hot_tub), label: "排行榜"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.my_library_add), label: "我的曲库"),
      //     BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置")
      //   ],
      // ),
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
        child: Column(
          children: [
            Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                height: MediaQuery.of(context).padding.top + 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.pinkAccent,
                      Colors.orangeAccent,
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                        )),
                    TextButton(
                      onPressed: () => _change(0),
                      child: Text("我的",
                          style: _currentIndex == 0 ? _selected : _unselect),
                    ),
                    TextButton(
                        onPressed: () => _change(1),
                        child: Text("推荐",
                            style: _currentIndex == 1 ? _selected : _unselect)),
                    TextButton(
                        onPressed: () => _change(2),
                        child: Text("发现",
                            style: _currentIndex == 2 ? _selected : _unselect)),
                    IconButton(
                        onPressed: () =>
                            Application.navigateToIos(context, "/search"),
                        icon: Icon(Icons.search, color: Colors.white)),
                  ],
                )),
            Expanded(
                child: getLine<int>(_keyPageView, initData: _currentIndex)
                    .addObserver((context, pack) => IndexedStack(
                          children: _getPageViewWidget(),
                          index: pack.data!,
                        )))
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
