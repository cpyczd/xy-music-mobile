/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 22:19:35
 * @LastEditTime: 2021-07-24 11:47:20
 */
import 'package:audio_service/audio_service.dart';
import 'package:event_bus/event_bus.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/event/player/index.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/store_config.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/service/player/player_service.dart';
import 'package:xy_music_mobile/util/index.dart';

class AudioPlayerBackageTask extends BackgroundAudioTask {
  final Logger logger = log;

  late final PlayerService service;

  ///构造器
  AudioPlayerBackageTask() {
    ///初始化使用的参数
    Application.applicationInit();
    // HttpUtil.logOpen();
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    await Store.flutterInit(initBox: false);
    service = PlayerService(this);
    var currMusic = service.musicModel!.getCurrentMusicEntity();
    //初始化当前播放的列表
    if (currMusic != null) {
      var mediaItem = AudioServiceBackground.queue!
          .firstWhere((element) => element.id == currMusic.uuid);
      AudioServiceBackground.setMediaItem(mediaItem);
      //发送一个初始化的事件过去
      AudioServiceBackground.sendCustomEvent(
          PlayerChangeEvent(service.playState, currMusic));
    }
    return;
  }

  ///加载此MediaItem并检查图片是否空的就直接替换
  void _loadImageCover(MediaItem mediaItem) {
    if (mediaItem.artUri == null) {
      //加载数据
      var music = MusicEntity.fromMap(mediaItem.extras!.cast());
      if (StringUtils.isBlank(music.picImage)) {
        //如果为空就获取图片的地址
        musicServiceProviderMange
            .getSupportProvider(music.source)
            .first
            .getPic(music)
            .then((value) {
          music.picImage = value;
          //更新到Hive数据存储中
          var dbData = service.musicModel!.findByUuid(music.uuid!);
          if (dbData != null) {
            dbData.picImage = value;
            service.musicModel!.updateByUuid(dbData);
          }

          var uri = Uri.parse(music.picImage!);
          //直接赋值
          var newMediaItem = mediaItem.copyWith(artUri: uri);
          AudioServiceBackground.queue!.remove(mediaItem);
          AudioServiceBackground.queue!.add(newMediaItem);
          notificationUpdateQueue();
          var currentMusic = service.musicModel?.currentMusic;
          if (currentMusic != null && currentMusic.uuid == mediaItem.id) {
            AudioServiceBackground.setMediaItem(newMediaItem);
          }
        });
      }
      if (StringUtils.isNotBlank(music.picImage)) {
        var uri = Uri.parse(music.picImage!);
        //直接赋值
        var newMediaItem = mediaItem.copyWith(artUri: uri);
        AudioServiceBackground.queue!.remove(mediaItem);
        AudioServiceBackground.queue!.add(newMediaItem);
        notificationUpdateQueue();
        var currentMusic = service.musicModel?.currentMusic;
        if (currentMusic != null && currentMusic.uuid == mediaItem.id) {
          AudioServiceBackground.setMediaItem(newMediaItem);
        }
      }
    }
  }

  @override
  Future<void> onPlay() async {
    log.d("onPlay() 开始播放");
    var model = service.musicModel!.getCurrentMusicEntity();
    if (model == null) {
      logger.w("没有音乐可以播放");
      return;
    }
    if (service.playState == PlayStatus.stop ||
        service.playState == PlayStatus.error) {
      await service.loadMusic(model);
    }
    var mediaItem = AudioServiceBackground.queue!
        .firstWhere((element) => element.id == model.uuid);
    AudioServiceBackground.setMediaItem(mediaItem);
    //检查图片
    _loadImageCover(mediaItem);
    //播放
    await service.play();
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
    await service.stop();
    var state = service.musicModel!.next();
    if (state) {
      AudioServiceBackground.setState(playing: false);
      return this.onPlay();
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
    return;
  }

  ///上一曲
  @override
  Future<void> onSkipToPrevious() async {
    log.d("onSkipToPrevious()=>播放上一曲");
    await service.stop();
    var state = service.musicModel!.previous();
    if (state) {
      AudioServiceBackground.setState(playing: false);
      return this.onPlay();
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

  ///显示控制器
  void _setShowControll() {
    var controll = <MediaControl>[];
    if (AudioServiceBackground.state.playing) {
      controll.add(MediaControl.pause);
    } else {
      controll.add(MediaControl.play);
    }
    if (service.musicModel!.hasNext()) {
      controll.add(MediaControl.skipToNext);
    }
    if (service.musicModel!.hasPrevious()) {
      controll.add(MediaControl.skipToPrevious);
    }
    AudioServiceBackground.setState(controls: controll);
  }

  ///进度调整
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
    //判断如果是当前播放的音乐的话就了忽略不处理!
    var music = MusicEntity.fromMap(item.extras!.cast());
    if (music.md5 == service.musicModel?.currentMusic?.md5) {
      return;
    }
    bool state =
        service.musicModel!.toPosition(MusicEntity.fromMap(item.extras!));
    if (!state) {
      return;
    }
    await service.stop();
    return this.onPlay();
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
    await Hive.close();
    await super.onStop();
    return;
  }

  ///添加音乐到播放列表
  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    var music = MusicEntity.fromMap(mediaItem.extras!);
    //先判断当前列表是否存在相同音乐
    var dbMusic =
        service.musicModel!.findWhere((item) => item.md5 == music.md5);
    if (dbMusic != null) {
      return;
    }
    AudioServiceBackground.queue!.add(mediaItem);
    await notificationUpdateQueue();
    service.musicModel!.addMusic(music);
    _setShowControll();

    ///发送播放列表改变事件
    AudioServiceBackground.sendCustomEvent(PlayListChangeEvent(
        PlayListChangeState.add, service.musicModel!.musicList.length, music));
    return;
  }

  ///移除音乐从播放列表
  @override
  Future<void> onRemoveQueueItem(MediaItem mediaItem) async {
    var currentMusic = service.musicModel!.getCurrentMusicEntity();
    var index = AudioServiceBackground.queue!
        .indexWhere((element) => element.id == mediaItem.id);
    if (index != -1) {
      AudioServiceBackground.queue!.removeAt(index);
    } else {
      return;
    }
    service.musicModel!.removeByUuid(mediaItem.id);
    await notificationUpdateQueue();
    _setShowControll();

    ///发送播放列表改变事件
    var music = MusicEntity.fromMap(mediaItem.extras!);
    AudioServiceBackground.sendCustomEvent(PlayListChangeEvent(
        PlayListChangeState.delete,
        service.musicModel!.musicList.length,
        music));
    //判断是否是当前的播放音乐
    if (currentMusic?.uuid == mediaItem.id) {
      if (service.musicModel!.currentIndex >= 0 &&
          service.musicModel!.musicList.isNotEmpty) {
        await this.onPlayFromMediaId(service
            .musicModel!.musicList[service.musicModel!.currentIndex].uuid!);
      } else {
        await service.stop();
      }
    }
    return super.onRemoveQueueItem(mediaItem);
  }

  ///通知更新队列
  Future<void> notificationUpdateQueue() {
    return AudioServiceBackground.setQueue(AudioServiceBackground.queue!);
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
      case "reloadMusic":
        service.loadPalyList();
        return Future.value(true);
      case "syncQueue":
        service.syncQueue();
        _setShowControll();
        return Future.value(true);
      case "nextPlay":
        var music = MusicEntity.fromMap((arguments as Map).cast());
        var dbMusic =
            service.musicModel!.findWhere((item) => item.md5 == music.md5);
        if (dbMusic == null) {
          service.musicModel!.addMusic(music);
          service.syncQueue();
          _setShowControll();
        } else {
          //已存在
          var index = service.musicModel!.musicList.indexOf(dbMusic);
          if (service.musicModel!.hasNext()) {
            service.musicModel!
                .moveIndex(index, service.musicModel!.currentIndex + 1);
          } else {
            service.musicModel!.removeAt(index);
            service.musicModel!.addMusic(dbMusic);
          }
        }
        return Future.value(true);
      case "loadNewList":
        if (arguments is List) {
          service.musicModel!.musicList.clear();
          service.musicModel!.addMusicAll(arguments
              .map((e) => MusicEntity.fromMap(Map<String, dynamic>.from(e)))
              .toList());
          service.syncQueue();
          _setShowControll();
          return Future.value(true);
        } else {
          return Future.error("arguments it need to be {List<Map>} ");
        }
      case "appendList":
        if (arguments is List) {
          service.musicModel!.addMusicAll(arguments
              .map((e) => MusicEntity.fromMap(Map<String, dynamic>.from(e)))
              .toList());
          service.syncQueue();
          _setShowControll();
          return Future.value(true);
        } else {
          return Future.error("arguments it need to be {List<Map>} ");
        }
      case "clear":
        service.musicModel!.clear();
        service.syncQueue();
        _setShowControll();
        await service.stop();
        //发送播放列表改变的事件
        AudioServiceBackground.sendCustomEvent(PlayListChangeEvent(
            PlayListChangeState.delete,
            service.musicModel!.musicList.length,
            null));
        return Future.value(true);
      case "getPlayMode":
        return Future.value(service.musicModel!.mode.name);
      case "setPlayMode":
        var mode = EnumUtil.enumFromString(PlayMode.values, arguments);
        if (mode != null) {
          service.musicModel!.setPlayMode(mode);
          //发送播放循环模式改变事件
          AudioServiceBackground.sendCustomEvent(
              PlayModeChangeEvent(mode: mode));
          return Future.value(true);
        } else {
          return Future.error("arguments it need to be {PlayMode} ");
        }
      case "moveToIndex":
        service.musicModel!
            .moveIndex(arguments["oldIndex"], arguments["newIndex"]);
        return Future.value(true);
      case "loadLyric":
        var lrcList = await service.loadLyric(arguments);
        if (lrcList == null) {
          return Future.error("lrc load fial");
        }
        return Future.value(lrcList.map((e) => e.toMap()).toList());
    }
    return Future.error("no action");
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
  static Future<MediaItem> pushQueue(MusicEntity entity) async {
    entity.uuid = _uuid.v1();
    Uri? uri;
    // if (StringUtils.isBlank(entity.picImage)) {
    //   //如果为空就获取图片的地址
    //   try {
    //     var url = await musicServiceProviderMange
    //         .getSupportProvider(entity.source)
    //         .first
    //         .getPic(entity);
    //     entity.picImage = url;
    //   } catch (e) {
    //     log.e("获取图片失败", e);
    //   }
    // }
    if (StringUtils.isNotBlank(entity.picImage)) {
      uri = Uri.parse(entity.picImage!);
    }

    var item = MediaItem(
        id: entity.uuid!,
        album: entity.albumName ?? "-",
        title: entity.songName,
        artist: entity.singer,
        duration: entity.duration,
        extras: entity.toMap(),
        artUri: uri);
    if (!AudioService.connected) {
      log.e("AudioService 未建立连接");
      Future.error("AudioService No connect");
    }
    await AudioService.addQueueItem(item);
    return item;
  }

  ///播放音乐根据MD5
  static Future<void> playByMd5(String md5) async {
    if (AudioService.queue != null) {
      for (var mediaItem in AudioService.queue!) {
        var music = MusicEntity.fromMap(mediaItem.extras!.cast());
        if (music.md5 == md5) {
          await AudioService.playFromMediaId(mediaItem.id);
          break;
        }
      }
    }
  }

  ///下一首播放
  static Future<bool> nextPlay(MusicEntity entity) {
    if (entity.uuid == null) {
      entity.uuid = _uuid.v1();
    }
    return _transformation(
      AudioService.customAction("nextPlay", entity.toMap()),
      cast: (val) => val is bool ? val : null,
    );
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
  static Future<bool> reloadMusic() {
    return AudioService.customAction("reloadMusic") as Future<bool>;
  }

  ///清空播放列表
  static Future<void> clear() async {
    await AudioService.customAction("clear");
  }

  ///主动刷新同步内存队列到 => AudioServie Queue队列里
  static Future<void> syncQueue() async {
    await AudioService.customAction("syncQueue");
  }

  ///向播放列队尾部追加数据
  static Future<List<MusicEntity>> appendList(List<MusicEntity> list) async {
    for (var item in list) {
      if (StringUtils.isBlank(item.uuid)) {
        item.uuid = _uuid.v1();
      }
    }
    await AudioService.customAction(
        "appendList", list.map((e) => e.toMap()).toList());
    return list;
  }

  ///清空现在的队列以传入的列表初始化队列 并自动同步 AudioServie Queue队列里
  static Future<List<MusicEntity>> loadNewList(List<MusicEntity> list) async {
    for (var item in list) {
      if (StringUtils.isBlank(item.uuid)) {
        item.uuid = _uuid.v1();
      }
    }
    await AudioService.customAction(
        "loadNewList", list.map((e) => e.toMap()).toList());
    return list;
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

  ///移动播放列表项顺序
  static Future<bool> moveToIndex(int oldIndex, int newIndex) {
    if (oldIndex < 0 || newIndex < 0) {
      return Future.error("index cannot be less than 0");
    }
    return _transformation(
      AudioService.customAction(
          "moveToIndex", {"oldIndex": oldIndex, "newIndex": newIndex}),
      cast: (val) => val is bool ? val : null,
    );
  }

  ///加载音乐歌词文件
  static Future<List<Lyric>> loadLyric(String uuid) {
    if (uuid.isEmpty) {
      return Future.error("uuid not empty");
    }
    return _transformation(AudioService.customAction("loadLyric", uuid),
        cast: (val) => val is List
            ? val
                .map((e) => Lyric.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : null);
  }

  static Future<T> _transformation<T>(Future future, {_OnCast? cast}) {
    return future.then<T>((value) {
      if (cast != null) {
        var res = cast(value);
        if (res == null) {
          throw new Exception("ERROR: " + value);
        }
        return res;
      }
      return value;
    }).onError((error, stackTrace) {
      log.e("_transformation:", error, stackTrace);
      return Future.error(error!, stackTrace);
    });
  }
}

typedef dynamic _OnCast(dynamic val);
