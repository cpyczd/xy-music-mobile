/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 21:07:33
 * @LastEditTime: 2021-07-05 22:18:31
 */
import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/util/widget_common.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';
import 'package:xy_music_mobile/view_widget/widget_lyric.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with MultDataLine, TickerProviderStateMixin {
  final String _startTimeKey = "startTimeKey";
  final String _endTimeKey = "endTimeKey";
  final String _controll = "Controll";

  PaletteGenerator? _paletteGenerator;

  ///主色调
  Color primaryColor = Color(AppTheme.getCurrentTheme().primaryColor);

  MusicEntity? _music;

  List<Lyric> lyric = [];

  LyricWidget? _lyricWidget;

  AnimationController? _lyricOffsetYController;

  Timer? _task;

  int currentOffset = 0;

  @override
  void initState() {
    super.initState();
    var mediaItem = AudioService.currentMediaItem;
    if (mediaItem != null) {
      _music = MusicEntity.fromMap(mediaItem.extras!);
      log.i("MusicEntity====> $_music");
      if (_music!.picImage != null) {
        //颜色分析
        PaletteGenerator.fromImageProvider(
                CachedNetworkImageProvider(_music!.picImage!),
                size: Size(500, 1000),
                region: Offset.zero & Size(10, 10))
            .then((value) {
          setState(() {
            _paletteGenerator = value;
            if (_paletteGenerator?.dominantColor?.color.value != null) {
              var reversalColor = AppTheme.reversal(
                  _paletteGenerator!.dominantColor!.color.value);
              //计算是否接近白色
              var Y = 0.2126 * reversalColor.red +
                  0.7152 * reversalColor.green +
                  0.0722 * reversalColor.blue;
              primaryColor = Y < 128 ? Colors.black : Colors.white;
              //设置状态栏的颜色
              setUiOverlayStyle(primaryColor == Colors.black
                  ? Brightness.light
                  : Brightness.dark);
            }
          });
        });
      }
    }

    Future.delayed(Duration.zero).then((value) {
      getLine<String>(_endTimeKey).setData(_music?.durationStr ?? "00:00");
    });

    ///加载歌词
    musicServiceProviderMange
        .getSupportProvider(MusicSourceConstant.wy)
        .first
        .getLyric(MusicEntity(
            songName: "songName",
            source: MusicSourceConstant.wy,
            duration: Duration.zero,
            songmId: "1847256510",
            originData: {}))
        .then((value) {
      setState(() {
        lyric = formatLyric(value);
        _lyricWidget = LyricWidget(lyric, 0, primaryColor: primaryColor);
        _task = Timer.periodic(Duration(milliseconds: 1000), (t) {
          currentOffset++;
          startLineAnim(currentOffset);
          _lyricWidget!.curLine = currentOffset;
        });
      });
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    _task?.cancel();
    _lyricOffsetYController?.stop();
    _lyricOffsetYController?.dispose();
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: Column(
                  children: [
                    _backWidget(),
                    Expanded(child: _lrcContent()),
                    _bottomControll()
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
              _music?.songName ?? "暂未播放",
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ))
      ],
    );
  }

  Widget _bottomControll() {
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
                      child: getLine(_controll, initData: 0.1)
                          .addObserver((context, pack) => SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.white,
                                    thumbColor: Colors.white,
                                    trackHeight: 1.5,
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    inactiveTrackColor: Colors.black26),
                                child: Slider(
                                  value: pack.data!,
                                  onChanged: (double value) {
                                    getLine(_controll).setData(value);
                                  },
                                ),
                              )))),
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

  Widget _lrcContent() {
    return Container(
      child: _lyricWidget == null
          ? Center(
              child: Text("歌词加载中...",
                  style: TextStyle(color: primaryColor, fontSize: 20)))
          : CustomPaint(
              painter: _lyricWidget,
            ),
    );
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
