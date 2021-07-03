/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-30 21:28:42
 * @LastEditTime: 2021-07-04 00:34:24
 */

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/event/player/index.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/audio_service_task.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';

class PlayerBottomControllre extends StatefulWidget {
  const PlayerBottomControllre({Key? key}) : super(key: key);

  @override
  _PlayerBottomControllreState createState() => _PlayerBottomControllreState();
}

class _PlayerBottomControllreState extends State<PlayerBottomControllre>
    with MultDataLine {
  final modeStyles = <Map<String, dynamic>>[
    {"mode": PlayMode.order, "icon": iconFont(hex16: 0xe658)},
    {"mode": PlayMode.loop, "icon": iconFont(hex16: 0xe6ae)},
    {"mode": PlayMode.random, "icon": iconFont(hex16: 0xe6a0)}
  ];

  final String _playSateKey = "_playSateKey";
  final String _playInfoKey = "_playInfoKey";
  final String _playProgressKey = "_playProgressKey";

  ///当前的播放模式控件样式
  Map<String, dynamic>? currentModeSryle;

  PlayerChangeEvent? _playEvent;

  @override
  void initState() {
    super.initState();
    PlayerTaskHelper.bus
        .on<PlayerChangeEvent>()
        .listen((PlayerChangeEvent event) {
      _playEvent = event;
      getLine(_playSateKey).setData(event.state);
      getLine(_playInfoKey).setData(event.musicEntity);
    });

    PlayerTaskHelper.bus
        .on<PlayerPositionChangedEvent>()
        .listen((PlayerPositionChangedEvent event) {
      // log.d("PlayerPositionChangedEvent ==> ${event.duration}");
      // getLine(_playInfoKey).setData(event.duration);
      getLine(_playProgressKey).setData(event.duration);
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Application.router.navigateTo(context, "/player",
                  transition: TransitionType.fadeIn);
            },
            child: getLine<MusicEntity>(_playInfoKey, initData: null)
                .addObserver((context, pack) => CircleAvatar(
                      backgroundImage: pack.data?.picImage != null
                          ? CachedNetworkImageProvider(pack.data!.picImage!)
                          : null,
                      child: getLine<Duration>(_playProgressKey,
                              initData: Duration.zero)
                          .addObserver((context, pack) {
                        var media = AudioService.currentMediaItem;
                        var total = media!.duration!.inSeconds;
                        double val =
                            pack.data!.inSeconds.toDouble() / total.toDouble();
                        return CircularProgressIndicator(
                          value: val,
                          strokeWidth: 2,
                          backgroundColor: Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(AppTheme.getCurrentTheme().primaryColor)),
                        );
                      }),
                    )),
          ),
          SizedBox.fromSize(
            size: Size.fromWidth(15),
          ),
          Expanded(
            child: getLine<MusicEntity>(_playInfoKey)
                .addObserver((context, pack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pack.data?.songName ?? "暂未播放",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          pack.data?.singer ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black54, fontSize: 11),
                        )
                      ],
                    )),
          ),
          SizedBox.fromSize(size: Size.fromWidth(15)),
          getLine(_playSateKey, initData: PlayStatus.stop).addObserver(
              (context, pack) => _createIconButton(
                  pack.data != PlayStatus.playing ? 0xe701 : 0xe67b,
                  callback: playOrPaused)),
          SizedBox.fromSize(size: Size.fromWidth(15)),
          _createIconButton(0xe602, callback: next),
          SizedBox.fromSize(size: Size.fromWidth(15)),
          _createIconButton(0xe6a7, callback: showMusicList),
        ],
      ),
    );
  }

  ///播放或者暂停
  void playOrPaused() {
    if (AudioService.playbackState.playing) {
      log.i("暂停");
      AudioService.pause();
    } else {
      log.i("开始播放");
      AudioService.play();
    }
  }

  ///下一首
  void next() async {
    log.d("停止Service线程");
    await AudioService.stop();
  }

  ///显示播放列表
  void showMusicList() {
    showCurrentPlayerList();
  }

  ///创建按钮
  Widget _createIconButton(int hex16, {VoidCallback? callback}) {
    return IconButton(
      onPressed: callback,
      icon: iconFont(
          hex16: hex16,
          size: 18,
          color: Color(AppTheme.getCurrentTheme().primaryColor)),
      padding: EdgeInsets.all(0),
      // splashColor: Colors.transparent,
      // highlightColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: 18, minHeight: 18),
    );
  }

  ///显示当前的播放列表
  void showCurrentPlayerList() async {
    PlayMode currentMode = await PlayerTaskHelper.getPlayMode();
    currentModeSryle =
        modeStyles.firstWhere((element) => element["mode"] == currentMode);
    var onModePressed = () async {
      PlayMode currentMode = await PlayerTaskHelper.getPlayMode();
      int index =
          modeStyles.indexWhere((element) => element["mode"] == currentMode);
      var i = (index + 1) % modeStyles.length;
      currentModeSryle = modeStyles[i];
      PlayerTaskHelper.setPlayMode(currentModeSryle!["mode"]);
    };
    showModalBottomSheet(
        backgroundColor:
            Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        context: context,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return Container(
                margin: EdgeInsets.only(top: 16),
                child: CustomScrollView(
                  slivers: [
                    SliverStickyHeader(
                      header: Container(
                        color: Color(
                            AppTheme.getCurrentTheme().scaffoldBackgroundColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton.icon(
                                style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                                onPressed: () {
                                  state(() {
                                    onModePressed();
                                  });
                                },
                                icon: currentModeSryle!["icon"],
                                label: Text(
                                    (currentModeSryle!["mode"] as PlayMode)
                                        .desc)),
                            Expanded(child: SizedBox()),
                            IconButton(
                                constraints: BoxConstraints(maxWidth: 25),
                                padding: EdgeInsets.zero,
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onPressed: () {},
                                icon: iconFont(hex16: 0xe603, size: 17)),
                            IconButton(
                                padding: EdgeInsets.zero,
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onPressed: () async {
                                  _removeMusic(
                                      await PlayerTaskHelper.getMusicList(),
                                      state);
                                },
                                icon: iconFont(hex16: 0xe67d, size: 17)),
                          ],
                        ),
                      ),
                      sliver: FutureBuilder<List<MusicEntity>>(
                        future: PlayerTaskHelper.getMusicList(),
                        builder: (context, sp) {
                          if (sp.hasData) {
                            var list = sp.data!;
                            var mediaItem = AudioService.currentMediaItem;
                            log.d("获取当前的播放Item=$mediaItem");
                            //当前播放的Index下标
                            var cindx = -1;
                            // var cindx = 0;
                            if (mediaItem != null) {
                              log.d("MusicList => $list");
                              cindx = list.indexWhere(
                                  (element) => element.uuid == mediaItem.id);
                            }
                            return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                              MusicEntity music = list[index];
                              return Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 23),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    (() {
                                      if (index == cindx) {
                                        return CircleAvatar(
                                          foregroundColor: Colors.greenAccent,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  music.picImage!),
                                        );
                                      } else {
                                        return Text(
                                            (index + 1) < 10
                                                ? "0${index + 1}"
                                                : "${(index + 1)}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black));
                                      }
                                    })(),
                                    SizedBox.fromSize(
                                      size: Size.fromWidth(15),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            music.songName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: cindx == index
                                                    ? Colors.redAccent.shade200
                                                    : Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox.fromSize(
                                            size: Size.fromHeight(5),
                                          ),
                                          Text(
                                            music.singer ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            BoxConstraints(maxWidth: 25),
                                        onPressed: () {},
                                        icon:
                                            iconFont(hex16: 0xe603, size: 17)),
                                    IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          _removeMusic([music], state);
                                        },
                                        icon: iconFont(hex16: 0xe67d, size: 17))
                                  ],
                                ),
                              );
                            }, childCount: list.length));
                          } else if (sp.connectionState ==
                              ConnectionState.waiting) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: CupertinoActivityIndicator(
                                  radius: 10,
                                ),
                              ),
                            );
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Text("空空的"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  ///移除音乐从播放列表
  void _removeMusic(List<MusicEntity> list, StateSetter setter) {
    PlayerTaskHelper.removeQueueByUuid(list.map((e) => e.uuid ?? "").toList());
    setter(() {});
  }
}
