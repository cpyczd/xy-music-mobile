/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 21:07:33
 * @LastEditTime: 2021-07-11 17:36:48
 */
import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/event/player/player_event.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/audio_service_task.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/util/widget_common.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';
import 'package:xy_music_mobile/view_widget/player_bottom_controller.dart';
import 'package:xy_music_mobile/view_widget/widget_lyric.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with MultDataLine, TickerProviderStateMixin {
  static final MODE_TYLE = CurrentPlayListUtil.modeStyles;

  static final int PLAY_ICON_HEX = 0xe701;
  static final int PAUSE_ICON_HEX = 0xe67b;

  late int currentPlayIconHex;

  final String _startTimeKey = "startTimeKey";
  final String _endTimeKey = "endTimeKey";
  final String _seekKey = "seekKey";
  final String _playModeKey = "_playModeKey";

  // PaletteGenerator? _paletteGenerator;

  ///主色调
  Color primaryColor = Colors.white;

  MusicEntity? _music;

  List<Lyric> lyric = [];

  LyricWidget? _lyricWidget;

  AnimationController? _lyricOffsetYController;

  StreamSubscription<PlayerPositionChangedEvent>? _streamPlayerPositionChange;
  StreamSubscription<PlayerChangeEvent>? _streamPlayerStateChange;
  StreamSubscription<PlayListChangeEvent>? _streamPlayerListChange;
  StreamSubscription<PlayModeChangeEvent>? _streamPlayModeChange;
  StreamSubscription<PlaybackState>? _streamPlaybackStateListener;

  ///歌词加载的placeholder
  String _placeholder = "";

  ///是否在拖拽进度条
  bool _seekDrag = false;

  ///是否在缓冲中
  bool _buffing = false;

  @override
  void initState() {
    super.initState();
    setUiOverlayStyle(Brightness.dark);
    if (AudioService.playbackState.playing) {
      currentPlayIconHex = PAUSE_ICON_HEX;
    } else {
      currentPlayIconHex = PLAY_ICON_HEX;
    }

    var mediaItem = AudioService.currentMediaItem;
    if (mediaItem != null) {
      _music = MusicEntity.fromMap(mediaItem.extras!);
      log.i("MusicEntity====> $_music");

      _initPlayControll();
      _loadLrc();
      _listenerPositionChanged();
      _listenerMusicChange();
      _listenerPlayListChange();
      _listenerPlayModeChange();
      _listenerPlaybackStateChange();
    }
  }

  ///音乐缓冲状态改变事件
  void _listenerPlaybackStateChange() {
    _streamPlaybackStateListener =
        AudioService.playbackStateStream.listen((event) {
      if (event.processingState == AudioProcessingState.buffering) {
        setState(() {
          _buffing = true;
        });
      } else {
        //NONE 加载完成
        setState(() {
          _buffing = false;
        });
      }
    });
  }

  ///初始化播放控制器状态
  void _initPlayControll() {
    PlayerTaskHelper.getPlayMode().then((value) {
      int index = MODE_TYLE.indexWhere((element) => element["mode"] == value);
      getLine(_playModeKey).setData(MODE_TYLE[index]);
    });
  }

  ///监听音乐的改变事件
  void _listenerMusicChange() {
    ///监听播放改变事件
    _streamPlayerStateChange = PlayerTaskHelper.bus
        .on<PlayerChangeEvent>()
        .listen((PlayerChangeEvent event) {
      if (_music!.uuid != event.musicEntity!.uuid) {
        setState(() {
          _music = event.musicEntity;
          // _changePrimaryColor();
          _loadLrc();
        });
      }
      if (event.state == PlayStatus.playing) {
        setState(() {
          currentPlayIconHex = PAUSE_ICON_HEX;
        });
      } else {
        setState(() {
          currentPlayIconHex = PLAY_ICON_HEX;
        });
      }
      //如果没有在播放就重置进度为0
      if (event.state != PlayStatus.playing &&
          event.state != PlayStatus.paused) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          getLine<Map<String, double>>(_seekKey)
              .setData({"max": 1.0, "current": 0.0});
          getLine(_startTimeKey).setData("00:00");
          getLine(_endTimeKey).setData("00:00");
        });
      }
    });
  }

  ///播放列表改变的事件
  void _listenerPlayListChange() {
    ///播放列表改变的事件
    _streamPlayerListChange =
        PlayerTaskHelper.bus.on<PlayListChangeEvent>().listen((event) {
      //如果列表为空的话就出发空事件刷新
      if (event.state == PlayListChangeState.delete && event.listLength == 0) {
        getLine<Map<String, double>>(_seekKey)
            .setData({"max": 1.0, "current": 0.0});
        getLine(_startTimeKey).setData("00:00");
        getLine(_endTimeKey).setData("00:00");
        setState(() {
          _music = null;
          _lyricWidget = null;
        });
      }
    });
  }

  ///播放循环模式改变的事件
  void _listenerPlayModeChange() {
    _streamPlayModeChange =
        PlayerTaskHelper.bus.on<PlayModeChangeEvent>().listen((event) {
      int index =
          MODE_TYLE.indexWhere((element) => element["mode"] == event.mode);
      getLine(_playModeKey).setData(MODE_TYLE[index]);
      ToastUtil.show(msg: event.mode.desc);
    });
  }

  ///颜色改变
  // void _changePrimaryColor() {
  //   if (_music!.picImage != null) {
  //     //颜色分析
  //     PaletteGenerator.fromImageProvider(
  //             CachedNetworkImageProvider(_music!.picImage!),
  //             size: Size(500, 1000),
  //             region: Offset.zero & Size(10, 10))
  //         .then((value) {
  //       setState(() {
  //         _paletteGenerator = value;
  //         if (_paletteGenerator?.dominantColor?.color.value != null) {
  //           var reversalColor = AppTheme.reversal(
  //               _paletteGenerator!.dominantColor!.color.value);
  //           //计算是否接近白色
  //           var Y = 0.2126 * reversalColor.red +
  //               0.7152 * reversalColor.green +
  //               0.0722 * reversalColor.blue;
  //           setState(() {
  //             primaryColor = Y < 128 ? Colors.black : Colors.white;
  //             //设置状态栏的颜色
  //             setUiOverlayStyle(primaryColor == Colors.black
  //                 ? Brightness.light
  //                 : Brightness.dark);
  //           });
  //         }
  //       });
  //     });
  //   }
  // }

  ///监听进度改变事件
  void _listenerPositionChanged() {
    _streamPlayerPositionChange = PlayerTaskHelper.bus
        .on<PlayerPositionChangedEvent>()
        .listen((PlayerPositionChangedEvent event) {
      if (_music == null || event.musicEntity!.uuid != _music!.uuid) {
        setState(() {
          _music = event.musicEntity;
        });
      }
      getLine<String>(_endTimeKey).setData(_music?.durationStr ?? "00:00");
      //设置进度条文字
      getLine(_startTimeKey)
          .setData(getTimeStamp(event.duration.inMilliseconds));
      //设置进度条进度
      if (!_seekDrag) {
        if (event.duration.inMilliseconds > 0) {
          getLine<Map<String, double>>(_seekKey).setData({
            "max": event.musicEntity!.duration.inMilliseconds.toDouble(),
            "current": event.duration.inMilliseconds.toDouble()
          });
        }
      }

      //设置歌词显示
      if (_lyricWidget != null && event.duration.inMilliseconds > 0) {
        int curLine =
            findLyricIndex(event.duration.inMilliseconds.toDouble(), lyric);
        if (!_lyricWidget!.isDragging) {
          if (_lyricWidget!.curLine != curLine) {
            startLineAnim(curLine);
            _lyricWidget!.curLine = curLine;
          }
        }
      }
    });
  }

  ///加载歌词
  void _loadLrc() {
    ///加载歌词
    setState(() {
      _placeholder = "加载歌词中...";
    });
    PlayerTaskHelper.loadLyric(_music!.uuid!).then((value) {
      setState(() {
        lyric = value;
        _lyricWidget = LyricWidget(lyric, 0);
      });
    }).onError((error, stackTrace) {
      log.e("歌词加载失败:$stackTrace --- error :$error");
      return Future.error(stackTrace);
    }).catchError((e) {
      setState(() {
        _placeholder = "歌词加载失败";
      });
      ToastUtil.show(msg: "歌词加载失败!");
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    _lyricOffsetYController?.stop();
    _lyricOffsetYController?.dispose();
    _streamPlayerPositionChange?.cancel();
    _streamPlayerStateChange?.cancel();
    _streamPlayerListChange?.cancel();
    _streamPlayModeChange?.cancel();
    _streamPlaybackStateListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black54,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _music?.picImage != null
                ? SliverFadeDelegate.vague(_music!.picImage!,
                    sigmaX: 50, sigmaY: 50)
                : SizedBox(),
            Container(
              color: Colors.black26,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: Column(
                  children: [
                    _backWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Center(
                        child: Text(
                          _music?.singer ?? "",
                          style: TextStyle(fontSize: 12, color: primaryColor),
                        ),
                      ),
                    ),
                    Expanded(child: _lrcContent()),
                    _bottomSeedControl(),
                    _playActionGroup()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///顶部TopBar
  Widget _backWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: primaryColor,
            ),
            onPressed: () => Application.router.pop(context),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Text(
              _buffing ? "音乐缓存中..." : _music?.songName ?? "暂未播放",
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ))
      ],
    );
  }

  ///底部控制栏
  Widget _bottomSeedControl() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              getLine<String>(_startTimeKey, initData: "00:00")
                  .addObserver((context, pack) => Text(
                        pack.data!,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      )),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: getLine<Map<String, double>>(_seekKey,
                              initData: {"max": 1.0, "current": 0.0})
                          .addObserver((context, pack) {
                        double current = pack.data!["current"]!.toDouble();
                        double max = pack.data!["max"]!.toDouble();
                        if (current > max) {
                          current = max;
                        }
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              thumbColor: Colors.white,
                              trackHeight: 1.5,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 8),
                              inactiveTrackColor: Colors.white38),
                          child: Slider(
                            value: current,
                            max: max,
                            min: 0.0,
                            onChanged: (val) {
                              _seekDrag = true;
                              getLine<Map<String, double>>(_seekKey).setData(
                                  {"max": pack.data!["max"]!, "current": val});
                            },
                            onChangeEnd: (double value) {
                              _seekDrag = false;
                              //触发进度改变事件
                              AudioService.seekTo(
                                  Duration(milliseconds: value.toInt()));
                            },
                          ),
                        );
                      }))),
              getLine<String>(_endTimeKey, initData: "00:00")
                  .addObserver((context, pack) => Text(
                        pack.data!,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      )),
            ],
          )
        ],
      ),
    );
  }

  ///音乐内容
  Widget _lrcContent() {
    return Container(
      margin: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      child: _lyricWidget == null
          ? Center(
              child: Text(_placeholder,
                  style: TextStyle(color: primaryColor, fontSize: 20)))
          : CustomPaint(
              painter: _lyricWidget,
            ),
    );
  }

  ///显示播放控制组Widget
  Widget _playActionGroup() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          getLine(_playModeKey).addObserver((context, pack) => IconButton(
                onPressed: _replacePlayMode,
                icon: pack.data!["icon"],
                color: primaryColor,
              )),
          IconButton(
            onPressed: _playPreviou,
            icon: iconFont(hex16: 0xe604),
            color: primaryColor,
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: _playSwatch,
            icon: iconFont(hex16: currentPlayIconHex),
            color: primaryColor,
          ),
          IconButton(
            onPressed: _playNext,
            icon: iconFont(hex16: 0xe602),
            color: primaryColor,
          ),
          IconButton(
              onPressed: _showCurrentPlayList,
              icon: iconFont(hex16: 0xe6a7),
              color: primaryColor),
        ],
      ),
    );
  }

  ///点击切换播放循环模式
  void _replacePlayMode() async {
    PlayMode currentMode = await PlayerTaskHelper.getPlayMode();
    int index =
        MODE_TYLE.indexWhere((element) => element["mode"] == currentMode);
    var i = (index + 1) % MODE_TYLE.length;
    var mode = MODE_TYLE[i];
    PlayerTaskHelper.setPlayMode(mode["mode"]);
  }

  ///切换控制播放或者暂停
  void _playSwatch() async {
    //如果是加载中就不做任何操作
    if (AudioService.playbackState.processingState ==
        AudioProcessingState.buffering) {
      log.i("_playSwatch() 加载音乐资源中不可进行播或者暂停的操作");
      return;
    }
    if (AudioService.playbackState.playing) {
      AudioService.pause();
      setState(() {
        currentPlayIconHex = PLAY_ICON_HEX;
      });
    } else {
      AudioService.play();
      setState(() {
        currentPlayIconHex = PAUSE_ICON_HEX;
      });
    }
  }

  ///显示播放列表
  void _showCurrentPlayList() {
    CurrentPlayListUtil.showCurrentPlayerList(context);
  }

  ///下一首
  void _playNext() async {
    await AudioService.skipToNext();
  }

  ///上一首
  void _playPreviou() async {
    await AudioService.skipToPrevious();
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
