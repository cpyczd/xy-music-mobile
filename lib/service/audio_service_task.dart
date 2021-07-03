/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 22:19:35
 * @LastEditTime: 2021-07-03 23:35:58
 */
import 'package:audio_service/audio_service.dart';
import 'package:event_bus/event_bus.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/player_service.dart';
import 'package:xy_music_mobile/util/index.dart';

class AudioPlayerBackageTask extends BackgroundAudioTask {
  final Logger logger = log;

  late final PlayerService service;

  AudioPlayerBackageTask() {
    Application.applicationInit();
    HttpUtil.logOpen();
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    logger.d("onStart() params: $params");
    service = PlayerService();
    return;
  }

  @override
  Future<void> onPlay() async {
    log.d("onPlay() Starting");
    var model = service.musicModel!.getCurrentMusicEntity();
    if (model == null) {
      logger.e("没有音乐可以播放");
      return;
    }
    if (service.playState == PlayStatus.stop ||
        service.playState == PlayStatus.error) {
      await service.loadMusic(model);
    }
    var mediaItem = AudioServiceBackground.queue!
        .firstWhere((element) => element.id == model.uuid);
    AudioServiceBackground.setMediaItem(mediaItem);
    var res = await service.play();
    logger.d("onPlay() 调用 Response:$res");
    var controls = [
      MediaControl.pause,
    ];
    if (service.musicModel!.hasNext()) {
      controls.add(MediaControl.skipToNext);
    }
    if (service.musicModel!.hasPrevious()) {
      controls.add(MediaControl.skipToPrevious);
    }
    AudioServiceBackground.setState(
      playing: true,
      position: service.position,
      systemActions: [
        MediaAction.seekTo,
      ],
      controls: controls,
    );
    return super.onPlay();
  }

  @override
  Future<void> onPause() async {
    await service.puase();
    var controls = [
      MediaControl.play,
    ];
    if (service.musicModel!.hasNext()) {
      controls.add(MediaControl.skipToNext);
    }
    if (service.musicModel!.hasPrevious()) {
      controls.add(MediaControl.skipToPrevious);
    }
    AudioServiceBackground.setState(
        playing: false, controls: controls, position: service.position);
    return super.onPause();
  }

  ///下一曲
  @override
  Future<void> onSkipToNext() async {
    log.d("onSkipToNext()=>播放下一曲");
    var state = service.musicModel!.next();
    if (state) {
      AudioServiceBackground.setState(playing: false);
      await service.stop();
      this.onPlay();
    } else {
      AudioServiceBackground.setState(
        playing: false,
        position: service.position,
        controls: [
          MediaControl.stop,
          MediaControl.skipToPrevious,
        ],
      );
    }
    return super.onSkipToNext();
  }

  ///上一曲
  @override
  Future<void> onSkipToPrevious() async {
    log.d("onSkipToPrevious()=>播放上一曲");
    var state = service.musicModel!.previous();
    if (state) {
      AudioServiceBackground.setState(playing: false);
      await service.stop();
      this.onPlay();
    } else {
      AudioServiceBackground.setState(
        playing: false,
        position: service.position,
        controls: [
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
      );
    }
    return super.onSkipToPrevious();
  }

  ///音量调整
  @override
  Future<void> onSeekTo(Duration position) {
    log.d("onSeekTo: position = $position");
    service.seekTo(position);
    return super.onSeekTo(position);
  }

  ///player播放到指定位置
  @override
  Future<void> onPlayFromMediaId(String mediaId) async {
    var index = AudioServiceBackground.queue!
        .indexWhere((element) => element.id == mediaId);
    if (index == -1) {
      return;
    }
    var item = AudioServiceBackground.queue![index];
    bool state =
        service.musicModel!.toPosition(MusicEntity.fromMap(item.extras!));
    if (!state) {
      return;
    }
    await service.stop();
    this.onPlay();
    return super.onPlayFromMediaId(mediaId);
  }

  ///player播放到指定位置
  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) {
    return this.onPlayFromMediaId(mediaItem.id);
  }

  @override
  Future<List<MediaItem>> onLoadChildren(String parentMediaId) {
    log.d("onLoadChildren: Params{parentMediaId = $parentMediaId}");
    return Future.value(AudioServiceBackground.queue);
  }

  @override
  Future<void> onClose() {
    return super.onClose();
  }

  @override
  Future<void> onStop() async {
    await service.dispose();
    await super.onStop();
    return;
  }

  ///添加音乐到播放列表
  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    AudioServiceBackground.queue!.add(mediaItem);
    service.musicModel!.addMusic(MusicEntity.fromMap(mediaItem.extras!));
    return;
  }

  ///移除音乐从播放列表
  @override
  Future<void> onRemoveQueueItem(MediaItem mediaItem) {
    AudioServiceBackground.queue!.remove(mediaItem);
    service.musicModel!.remove(MusicEntity.fromMap(mediaItem.extras!));
    return super.onRemoveQueueItem(mediaItem);
  }

  @override
  Future onCustomAction(String action, arguments) async {
    if (StringUtils.isBlank(action)) {
      return Future.error("action not null");
    }
    logger.i(
        "onCustomAction action = $action arguments = $arguments  argumentsType = ${arguments.runtimeType.toString()}");

    switch (action) {
      case "getMusicList":
        return Future.value(
            service.musicModel!.musicList.map((e) => e.toMap()).toList());
      case "loadQueue":
        service.loadPalyList();
        return Future.value(true);
      case "syncQueue":
        service.syncQueue();
        return Future.value(true);
      case "loadNewList":
        if (arguments is List<MusicEntity>) {
          service.musicModel!.musicList.clear();
          service.musicModel!.addMusicAll(arguments);
          service.syncQueue();
          return Future.value(true);
        } else {
          return Future.error("arguments it need to be {List<MusicEntity>} ");
        }
      case "appendList":
        if (arguments is List<MusicEntity>) {
          service.musicModel!.addMusicAll(arguments);
          service.syncQueue();
          return Future.value(true);
        } else {
          return Future.error("arguments it need to be {List<MusicEntity>} ");
        }
      case "getPlayMode":
        return Future.value(service.musicModel!.mode.name);
      case "setPlayMode":
        var mode = EnumUtil.enumFromString(PlayMode.values, arguments);
        if (mode != null) {
          service.musicModel!.mode = mode;
          return Future.value(true);
        } else {
          return Future.error("arguments it need to be {PlayMode} ");
        }
    }
    return Future.error("not action");
  }
}

///播放帮助类
class PlayerTaskHelper {
  static final EventBus bus = EventBus();

  static bool _isInitEvent = false;

  static final Uuid _uuid = Uuid();

  ///初始化监听器
  static void flutterInitListener() {
    if (_isInitEvent) return;
    AudioService.customEventStream.listen((event) {
      bus.fire(event);
    });
    _isInitEvent = true;
  }

  ///添加一首音乐到列队
  static void pushQueue(MusicEntity entity) async {
    entity.uuid = _uuid.v1();
    Uri? uri;
    if (StringUtils.isBlank(entity.picImage)) {
      //如果为空就获取图片的地址
      await musicServiceProviderMange
          .getSupportProvider(entity.source)
          .first
          .getPic(entity);
    }
    if (StringUtils.isNotBlank(entity.picImage)) {
      uri = Uri.parse(entity.picImage!);
    }

    var item = MediaItem(
        id: entity.uuid!,
        album: entity.albumName ?? "-",
        title: entity.songName,
        artist: entity.singer,
        duration: Duration(milliseconds: entity.duration),
        extras: entity.toMap(),
        artUri: uri);
    AudioService.addQueueItem(item);
  }

  ///获取播放Model
  static Future<List<MusicEntity>> getMusicList() {
    return _transformation(AudioService.customAction("getMusicList"),
        cast: (val) => val is List
            ? val
                .map((e) => MusicEntity.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : null);
  }

  ///重新从存储中加载数据到内存队列中去
  static Future<bool> loadQueue() {
    return AudioService.customAction("loadQueue") as Future<bool>;
  }

  ///主动刷新同步内存队列到 => AudioServie Queue队列里
  static Future<bool> syncQueue() {
    return AudioService.customAction("syncQueue") as Future<bool>;
  }

  ///向播放列队尾部追加数据
  static Future<bool> appendList(List<MusicEntity> list) {
    return AudioService.customAction(
        "appendList", list.map((e) => e.toMap()).toList()) as Future<bool>;
  }

  ///清空现在的队列以传入的列表初始化队列 并自动同步 AudioServie Queue队列里
  static Future<bool> loadNewList(List<MusicEntity> list) {
    return AudioService.customAction(
        "loadNewList", list.map((e) => e.toMap()).toList()) as Future<bool>;
  }

  ///获取播放循环模式
  static Future<PlayMode> getPlayMode() {
    return AudioService.customAction("getPlayMode")
        .then((value) => EnumUtil.enumFromString(PlayMode.values, value)!);
  }

  ///设置播放循环模式
  static Future<bool> setPlayMode(PlayMode mode) {
    return _transformation(
      AudioService.customAction("setPlayMode", mode.name),
      cast: (val) => val is bool ? val : null,
    );
  }

  ///从队列移除批量数据 根据UUID
  static void removeQueueByUuid(List<String> uuids) {
    AudioService.queue!
        .where((element) => uuids.indexWhere((uid) => uid == element.id) != -1)
        .forEach((element) => AudioService.removeQueueItem(element));
  }

  static Future<T> _transformation<T>(Future future, {_OnCast? cast}) {
    return future.then((value) {
      if (cast != null) {
        var res = cast(value);
        if (res == null) {
          throw new Exception(value);
        }
        return res;
      }
      return value;
    });
  }
}

typedef dynamic _OnCast(dynamic val);
