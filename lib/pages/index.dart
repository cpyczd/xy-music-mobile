/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:07:50
 * @LastEditTime: 2021-06-01 23:21:17
 */

import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/util/index.dart';
import '../application.dart';
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
    with AutomaticKeepAliveClientMixin<HomePage> {
  late final StreamController<int> _currentIndexStream;

  late DateTime _lastPressedAt; //上次点击时间

  ///创建ViewPage页面对象
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
    _currentIndexStream = StreamController();
    super.initState();
  }

  @override
  void dispose() {
    _currentIndexStream.close();
    super.dispose();
  }

  ///页面改变时间
  void _change(index) {
    _currentIndexStream.sink.add(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: BottomNavigationBar(
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
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
      //         icon: Icon(Icons.my_library_add), label: "我的"),
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: "搜索"),
      //     BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置")
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.redAccent.shade100,
        onPressed: () {
          // Application.navigateToIos(context, "/player");
          Application.router.navigateTo(context, "/player",
              transition: TransitionType.inFromBottom);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 100,
        width: double.infinity,
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.music_note_outlined),
                onPressed: () => _change(0),
              ),
              IconButton(
                  icon: Icon(Icons.hot_tub), onPressed: () => _change(1)),
              IconButton(
                  icon: Icon(Icons.my_library_add),
                  onPressed: () => _change(2)),
              // TextIconButton(
              //     icon: Icon(Icons.search),
              //     text: "搜索",
              //     onPressed: () => _change(4)),
              IconButton(
                  icon: Icon(Icons.settings), onPressed: () => _change(3)),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt) >
                  Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            _lastPressedAt = DateTime.now();
            ToastUtil.show(msg: "再按一次退出程序");
            return false;
          }
          return true;
        },
        child: StreamBuilder(
          initialData: 0,
          stream: _currentIndexStream.stream,
          builder: (context, snapshot) => IndexedStack(
            children: _getPageViewWidget(),
            index: snapshot.data as int,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
