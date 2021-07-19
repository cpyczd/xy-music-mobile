import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/view_widget/widget_lyric.dart';

class LyricPage extends StatefulWidget {
  LyricPage();

  @override
  _LyricPageState createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> with TickerProviderStateMixin {
  LyricWidget? _lyricWidget;
  List<Lyric>? lyrics;
  AnimationController? _lyricOffsetYController;

  Timer? dragEndTimer; // 拖动结束任务
  Function? dragEndFunc;
  Duration dragEndDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((call) {
      // _request();
    });

    dragEndFunc = () {
      if (_lyricWidget!.isDragging) {
        setState(() {
          _lyricWidget!.isDragging = false;
        });
      }
    };
  }

  // void _request() async {
  //   _lyricData =
  //       await NetUtils.getLyricData(context, params: {'id': curSongId});
  //   setState(() {
  //     lyrics = Utils.formatLyric(_lyricData.lrc.lyric);
  //     _lyricWidget = LyricWidget(lyrics, 0);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print('lyric_build');
    // 当前歌的id变化之后要重新获取歌词
    // if (curSongId != widget.model.curSong.id) {
    //   lyrics = null;
    //   curSongId = widget.model.curSong.id;
    //   _request();
    // }

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: lyrics == null
            ? Container(
                alignment: Alignment.center,
                child: Text(
                  '歌词加载中...',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            : GestureDetector(
                onTapDown: _lyricWidget!.isDragging
                    ? (e) {
                        if (e.localPosition.dx > 0 &&
                            e.localPosition.dx < 100 &&
                            e.localPosition.dy >
                                _lyricWidget!.canvasSize.height / 2 - 100 &&
                            e.localPosition.dy <
                                _lyricWidget!.canvasSize.height / 2 + 100) {
                          // widget.model.seekPlay(_lyricWidget.dragLineTime);
                        }
                      }
                    : null,
                onVerticalDragUpdate: (e) {
                  if (!_lyricWidget!.isDragging) {
                    setState(() {
                      _lyricWidget!.isDragging = true;
                    });
                  }
                  _lyricWidget!.offsetY += e.delta.dy;
                },
                onVerticalDragEnd: (e) {
                  // 拖动防抖
                  cancelDragTimer();
                },
                child: StreamBuilder<String>(
                  // stream: widget.model.curPositionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var curTime = double.parse(snapshot.data!
                          .substring(0, snapshot.data!.indexOf('-')));
                      // 获取当前在哪一行
                      int curLine = findLyricIndex(curTime, lyrics!);
                      if (!_lyricWidget!.isDragging) {
                        startLineAnim(curLine);
                      }
                      // 给 customPaint 赋值当前行
                      _lyricWidget!.curLine = curLine;
                      var size = MediaQuery.of(context).size;
                      return CustomPaint(
                        size: Size(
                            size.width,
                            size.height -
                                kToolbarHeight -
                                150 -
                                50 -
                                MediaQuery.of(context).padding.top -
                                120),
                        painter: _lyricWidget,
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ));
  }

  void cancelDragTimer() {
    if (dragEndTimer != null) {
      if (dragEndTimer!.isActive) {
        dragEndTimer!.cancel();
        dragEndTimer = null;
      }
    }
    // dragEndTimer = Timer(dragEndDuration, dragEndFunc);
  }

  /// 开始下一行动画
  void startLineAnim(int curLine) {
    // 判断当前行和 customPaint 里的当前行是否一致，不一致才做动画
    if (_lyricWidget!.curLine != curLine) {
      // 如果动画控制器不是空，那么则证明上次的动画未完成，
      // 未完成的情况下直接 stop 当前动画，做下一次的动画
      if (_lyricOffsetYController != null) {
        _lyricOffsetYController!.stop();
      }

      // 初始化动画控制器，切换歌词时间为300ms，并且添加状态监听，
      // 如果为 completed，则消除掉当前controller，并且置为空。
      _lyricOffsetYController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _lyricOffsetYController!.dispose();
            _lyricOffsetYController = null;
          }
        });
      // 计算出来当前行的偏移量
      var end = _lyricWidget!.computeScrollY(curLine) * -1;
      // 起始为当前偏移量，结束点为计算出来的偏移量
      Animation animation =
          Tween<double>(begin: _lyricWidget!.offsetY, end: end)
              .animate(_lyricOffsetYController!);
      // 添加监听，在动画做效果的时候给 offsetY 赋值
      _lyricOffsetYController!.addListener(() {
        _lyricWidget!.offsetY = animation.value;
      });
      // 启动动画
      _lyricOffsetYController!.forward();
    }
  }
}
