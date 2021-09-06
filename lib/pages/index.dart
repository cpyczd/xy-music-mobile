/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:07:50
 * @LastEditTime: 2021-07-24 12:11:44
 */

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/service/player/audio_service_task.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/player_bottom_controller.dart';
import 'my_music_page.dart';
import 'setting_page.dart';
import 'song_square_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        AutomaticKeepAliveClientMixin<HomePage>,
        MultDataLine,
        WidgetsBindingObserver {
  int _currentIndex = 1;

  final String _keyPageView = "PageViewKey";

  //上次点击时间
  DateTime? _lastPressedAt;

  final TextStyle _selected = TextStyle(color: Colors.white, fontSize: 18);

  final TextStyle _unselect = TextStyle(color: Colors.white60, fontSize: 15);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Future.delayed(Duration.zero).then((value) async {
      log.d("初始化Task任务 开始");
      var state = await AudioService.start(
          backgroundTaskEntrypoint: _entrypoint, params: {"test": "success"});
      log.d("初始化Task任务结束 结果=>:$state");
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    //关闭Hive存储
    Hive.close();
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        log.d("app in resumed");
        break;
      case AppLifecycleState.inactive:
        log.d("app in inactive");
        break;
      case AppLifecycleState.paused:
        log.d("app in paused");
        break;
      case AppLifecycleState.detached:
        log.d("app in detached");
        break;
    }
  }

  ///创建ViewPage页面对象
  /// 主页曲库（搜索）推荐歌单、排行榜、我的曲库、设置
  List<Widget> _getPageViewWidget() {
    List<Widget> list = [
      MyMusicPage(),
      SongSquarePage(),
      // HotPage(),
      // SettingPage()
    ];
    return list;
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
    return AudioServiceWidget(
      child: Scaffold(
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
                          onPressed: () {
                            // Application.navigateToIos(context, "/setting");
                          },
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
                              style:
                                  _currentIndex == 1 ? _selected : _unselect)),
                      // TextButton(
                      //     onPressed: () => _change(2),
                      //     child: Text("发现",
                      //         style:
                      //             _currentIndex == 2 ? _selected : _unselect)),
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
                          ))),
              Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0.0, 10.0), //阴影xy轴偏移量
                      blurRadius: 12.0, //阴影模糊程度
                      spreadRadius: 1.5 //阴影扩散程度
                      )
                ]),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: PlayerBottomControllre(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

void _entrypoint() async =>
    await AudioServiceBackground.run(() => AudioPlayerBackageTask());
