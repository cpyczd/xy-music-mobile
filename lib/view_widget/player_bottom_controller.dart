/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-30 21:28:42
 * @LastEditTime: 2021-07-11 17:28:05
 */

import 'dart:async';

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
import 'package:xy_music_mobile/view_widget/text_icon_button.dart';
import 'package:xy_music_mobile/common/source_constant.dart';

class PlayerBottomControllre extends StatefulWidget {
  const PlayerBottomControllre({Key? key}) : super(key: key);

  @override
  _PlayerBottomControllreState createState() => _PlayerBottomControllreState();
}

class _PlayerBottomControllreState extends State<PlayerBottomControllre>
    with MultDataLine {
  final String _playSateKey = "_playSateKey";
  final String _playInfoKey = "_playInfoKey";
  final String _playProgressKey = "_playProgressKey";

  MusicEntity? currentMusic;

  StreamSubscription<PlayerChangeEvent>? _streamPlayerStateChange;
  StreamSubscription<PlayerPositionChangedEvent>? _streamPlayerPositionChange;
  StreamSubscription<PlayListChangeEvent>? _streamPlayerListChange;
  StreamSubscription<PlaybackState>? _streamPlaybackStateListener;

  @override
  void initState() {
    super.initState();

    ///监听播放改变事件
    _streamPlayerStateChange = PlayerTaskHelper.bus
        .on<PlayerChangeEvent>()
        .listen((PlayerChangeEvent event) {
      currentMusic = event.musicEntity;
      getLine(_playSateKey).setData(event.state);
      getLine(_playInfoKey).setData(event.musicEntity);
      //如果没有在播放就重置进度为0
      if (event.state != PlayStatus.playing &&
          event.state != PlayStatus.paused) {
        Future.delayed(Duration(seconds: 2)).then((value) =>
            getLine<Duration>(_playProgressKey)
                .setData(Duration(milliseconds: 0)));
      }
    });

    ///监听进度改变事件
    _streamPlayerPositionChange = PlayerTaskHelper.bus
        .on<PlayerPositionChangedEvent>()
        .listen((PlayerPositionChangedEvent event) {
      if (currentMusic == null ||
          event.musicEntity!.uuid != currentMusic!.uuid) {
        currentMusic = event.musicEntity;
        getLine(_playSateKey).setData(PlayStatus.playing);
        getLine(_playInfoKey).setData(event.musicEntity);
      }
      getLine<Duration>(_playProgressKey).setData(event.duration);
    });

    ///播放列表改变的事件
    _streamPlayerListChange =
        PlayerTaskHelper.bus.on<PlayListChangeEvent>().listen((event) {
      //如果列表为空的话就出发空事件刷新
      if (event.state == PlayListChangeState.delete && event.listLength == 0) {
        getLine(_playSateKey).setData(PlayStatus.stop);
        getLine(_playInfoKey).setData(null);
      }
    });

    _streamPlaybackStateListener =
        AudioService.playbackStateStream.listen((event) {
      if (getLine(_playInfoKey).currentData?.data == null) {
        return;
      }
      if (event.processingState == AudioProcessingState.buffering) {
        getLine(_playInfoKey).setParams({"buffing": true});
      } else {
        //NONE 加载完成
        getLine(_playInfoKey).setParams({"buffing": false});
      }
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    _streamPlayerPositionChange?.cancel();
    _streamPlayerStateChange?.cancel();
    _streamPlayerListChange?.cancel();
    _streamPlaybackStateListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => Application.router
            .navigateTo(context, "/player", transition: TransitionType.fadeIn),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getLine<MusicEntity>(_playInfoKey, showNull: true)
                .addObserver((context, pack) => CircleAvatar(
                      backgroundImage: pack.data?.picImage != null
                          ? CachedNetworkImageProvider(pack.data!.picImage!)
                          : null,
                      child: getLine<Duration>(_playProgressKey,
                              initData: Duration.zero)
                          .addObserver((context, pack) {
                        var media = AudioService.currentMediaItem;
                        double val = 0;
                        if (media != null) {
                          var total = media.duration!.inMilliseconds;
                          if (total > 0) {
                            val = pack.data!.inMilliseconds.toDouble() /
                                total.toDouble();
                          }
                        }
                        return CircularProgressIndicator(
                          value: val,
                          strokeWidth: 2.5,
                          backgroundColor: Colors.black38,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(AppTheme.getCurrentTheme().primaryColor)),
                        );
                      }),
                    )),
            SizedBox.fromSize(
              size: Size.fromWidth(15),
            ),
            Expanded(
              child: getLine<MusicEntity>(_playInfoKey, showNull: true)
                  .addObserver((context, pack) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pack.params?["buffing"] ?? false
                                ? "缓存中..."
                                : pack.data?.songName ?? "暂未播放",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            pack.params?["buffing"] ?? false
                                ? "稍等一下马上就好"
                                : pack.data?.singer ?? "",
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 11),
                          )
                        ],
                      )),
            ),
            SizedBox.fromSize(size: Size.fromWidth(15)),
            getLine(_playSateKey, initData: PlayStatus.stop).addObserver(
                (context, pack) => _createIconButton(
                    pack.data != PlayStatus.playing &&
                            pack.data != PlayStatus.loading
                        ? 0xe701
                        : 0xe67b,
                    callback: playOrPaused)),
            SizedBox.fromSize(size: Size.fromWidth(15)),
            _createIconButton(0xe602, callback: next),
            SizedBox.fromSize(size: Size.fromWidth(15)),
            _createIconButton(0xe6a7, callback: showMusicList),
          ],
        ),
      ),
    );
  }

  ///播放或者暂停
  void playOrPaused() {
    //如果是加载中就不做任何操作
    if (AudioService.playbackState.processingState ==
        AudioProcessingState.buffering) {
      log.i("playOrPaused 加载音乐资源中不可进行播或者暂停的操作");
      return;
    }
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
    await AudioService.skipToNext();
  }

  ///显示播放列表
  void showMusicList() {
    CurrentPlayListUtil.showCurrentPlayerList(context);
  }

  ///创建按钮
  Widget _createIconButton(int hex16,
      {VoidCallback? callback, double size = 23}) {
    return IconButton(
      onPressed: callback,
      icon: iconFont(
          hex16: hex16,
          size: size,
          color: Color(AppTheme.getCurrentTheme().primaryColor)),
      padding: EdgeInsets.all(0),
      constraints: BoxConstraints(maxWidth: 26, minWidth: 26),
    );
  }
}

///显示当前播放列表工具类
class CurrentPlayListUtil {
  static final modeStyles = <Map<String, dynamic>>[
    {"mode": PlayMode.order, "icon": iconFont(hex16: 0xe6af)},
    {"mode": PlayMode.loop, "icon": iconFont(hex16: 0xe6ae)},
    {"mode": PlayMode.random, "icon": iconFont(hex16: 0xe6a0)}
  ];

  ///当前的播放模式控件样式
  static Map<String, dynamic>? _currentModeSryle;

  ///显示当前的播放列表
  static void showCurrentPlayerList(BuildContext context) async {
    PlayMode currentMode = await PlayerTaskHelper.getPlayMode();
    _currentModeSryle =
        modeStyles.firstWhere((element) => element["mode"] == currentMode);

    //显示控件
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
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverStickyHeader(
                      header: _sliverHeader(state),
                      sliver: _sliverContent(state),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  ///返回Sliver头部构建Widget
  static Widget _sliverHeader(StateSetter state) {
    return Container(
      color: Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              onPressed: () {
                _replacePlayMode(state);
              },
              icon: _currentModeSryle!["icon"],
              label: Text((_currentModeSryle!["mode"] as PlayMode).desc)),
          Expanded(child: SizedBox()),
          IconButton(
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: () {},
              icon: iconFont(hex16: 0xe603, size: 20)),
          IconButton(
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: () async {
                _removeMusic(await PlayerTaskHelper.getMusicList(), state);
              },
              icon: iconFont(hex16: 0xe67d, size: 20)),
        ],
      ),
    );
  }

  ///返回Sliver内容List构造Widget
  static Widget _sliverContent(StateSetter state) {
    return FutureBuilder<List<MusicEntity>>(
      future: PlayerTaskHelper.getMusicList(),
      builder: (context, sp) {
        if (sp.hasData && sp.data!.isNotEmpty) {
          var list = sp.data!;
          var mediaItem = AudioService.currentMediaItem;
          //当前播放的Index下标
          var cindx = -1;
          if (mediaItem != null) {
            cindx = list.indexWhere((element) => element.uuid == mediaItem.id);
          }
          return SliverReorderableList(
            onReorder: (oldIndex, newIndex) {
              //移动列表
              if (newIndex - 1 >= 0 && newIndex - 1 < list.length) {
                newIndex--;
              }
              state(() {
                var old = list[oldIndex];
                list.removeAt(oldIndex);
                list.insert(newIndex, old);
              });
              PlayerTaskHelper.moveToIndex(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              MusicEntity music = list[index];
              return ReorderableDelayedDragStartListener(
                index: index,
                key: ValueKey(music.uuid),
                child: Material(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 23),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: InkWell(
                      onTap: () => _playTo(music, state),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (() {
                            if (index == cindx) {
                              return CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(music.picImage!),
                              );
                            } else {
                              return Text(
                                  (index + 1) < 10
                                      ? "0${index + 1}"
                                      : "${(index + 1)}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black));
                            }
                          })(),
                          SizedBox.fromSize(
                            size: Size.fromWidth(15),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Text(
                                        "[ ${music.source.desc} ]",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.green),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        music.singer ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                              icon: iconFont(hex16: 0xe603, size: 20)),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _removeMusic([music], state);
                              },
                              icon: iconFont(hex16: 0xe67d, size: 20))
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: list.length,
          );
        } else if (sp.connectionState == ConnectionState.waiting) {
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
              child:
                  TextIconButton(icon: svg(name: "empty"), text: "还没音乐快去听歌吧!"),
            ),
          );
        }
      },
    );
  }

  ///点击切换播放循环模式
  static void _replacePlayMode(StateSetter setter) async {
    PlayMode currentMode = await PlayerTaskHelper.getPlayMode();
    int index =
        modeStyles.indexWhere((element) => element["mode"] == currentMode);
    var i = (index + 1) % modeStyles.length;
    _currentModeSryle = modeStyles[i];
    PlayerTaskHelper.setPlayMode(_currentModeSryle!["mode"]);
    setter(() {});
  }

  ///移除音乐从播放列表
  static void _removeMusic(List<MusicEntity> list, StateSetter setter) {
    PlayerTaskHelper.removeQueueByUuid(list.map((e) => e.uuid ?? "").toList());
    setter(() {});
  }

  ///播放到指定的位置
  static void _playTo(MusicEntity music, StateSetter setter) async {
    await AudioService.playFromMediaId(music.uuid!);
    setter(() {});
  }
}
