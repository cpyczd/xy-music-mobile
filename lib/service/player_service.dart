/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 18:22:11
 * @LastEditTime: 2021-07-10 00:15:38
 */

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:xy_music_mobile/common/event/player/index.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/store_config.dart';
import 'package:xy_music_mobile/model/lyric.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/play_list_model.dart';
import 'package:xy_music_mobile/util/index.dart';

import 'audio_service_task.dart';

///播放服务
class PlayerService {
  final Logger logger = log;

  final String _boxDb = "xy-music-play-storeDb";
  final String _boxModelKey = "xy-music-play-storeDb-key-model1";
  final String _playerInstanceId = "xy-music-play-id";

  late final Box<PlayListModel> _db;

  final AudioPlayerBackageTask backageTask;

  ///播放列表
  PlayListModel? _playListModel;

  AudioPlayer? _audioPlayer;

  ///播放状态
  PlayStatus _status = PlayStatus.stop;

  PlayStatus get playState => this._status;

  set playState(PlayStatus status) => this._status = status;

  PlayListModel? get musicModel => _playListModel;

  ///当前播放的进度
  Duration position = Duration.zero;

  PlayerService(this.backageTask) {
    _playListModel = PlayListModel(musicList: []);
    Store.openBox<PlayListModel>(_boxDb).then((value) {
      _db = value;
      loadPalyList();
    }).catchError((e) {
      logger.e("PlayerService===>初始化DbBox失败", e);
    });

    //初始化播放器
    _audioPlayer =
        AudioPlayer(mode: PlayerMode.MEDIA_PLAYER, playerId: _playerInstanceId);
  }

  ///加载播放列表
  void loadPalyList() {
    //从Hive进行加载
    if (_db.containsKey(_boxModelKey)) {
      //如果存在就读取
      var obj = _db.get(_boxModelKey);
      if (obj != null) {
        _playListModel = obj;
        logger.i("Task从数据库读取到的数据:===>$_playListModel");
      }
    } else {
      _db.put(_boxModelKey, _playListModel!);
    }
    //设置保存触发方法
    _playListModel!.setSaveFun(() {
      _playListModel!.save();
    });
    this.syncQueue();
  }

  ///同步播放队列
  void syncQueue() {
    var mediaList = _playListModel!.musicList
        .map((e) => MediaItem(
            id: e.uuid!,
            album: e.albumName ?? "-",
            title: e.songName,
            artist: e.singer,
            duration: e.duration,
            extras: e.toMap(),
            artUri: _getImage(e)))
        .toList();
    AudioServiceBackground.setQueue(mediaList);
  }

  Uri? _getImage(MusicEntity entity) {
    if (entity.picImage == null || entity.picImage!.isEmpty) {
      musicServiceProviderMange
          .getSupportProvider(entity.source)
          .first
          .getPic(entity)
          .then((value) {});
      return null;
    }
    return Uri.parse(entity.picImage!);
  }

  void _createPlayerInstance() {
    _audioPlayer?.stop();
    _status = PlayStatus.stop;
    _audioPlayer =
        AudioPlayer(mode: PlayerMode.MEDIA_PLAYER, playerId: _playerInstanceId);
  }

  ///加载音乐
  Future<bool> loadMusicForUrl(String url) async {
    _createPlayerInstance();
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.buffering);
    _status = PlayStatus.loading;

    bool s = await _audioPlayer!.setUrl(url) == 1 ? true : false;
    if (s) {
      _status = PlayStatus.ready;
      AudioServiceBackground.setState(
          processingState: AudioProcessingState.ready);
      initListener();
    } else {
      _status = PlayStatus.error;
      AudioServiceBackground.setState(
          processingState: AudioProcessingState.error);
    }
    return s;
  }

  ///加载音乐 根据音乐数据Model
  Future<bool> loadMusic(MusicEntity entity) async {
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.buffering);
    _status = PlayStatus.loading;
    //发送Laoding事件
    AudioServiceBackground.sendCustomEvent(PlayerChangeEvent(_status, entity));
    if (entity.playUrl != null && entity.playUrl!.isNotEmpty) {
      return await loadMusicForUrl(entity.playUrl!);
    }
    var service =
        musicServiceProviderMange.getSupportProvider(entity.source).first;
    try {
      await service.getPlayUrl(entity);
      //播放URL加载成功后保存到数据库
      _playListModel!.save();
    } catch (e) {
      logger.e("PlayerService => 音乐解析失败");
      ToastUtil.show(msg: "音乐播放失败");
      //直接进行播放下一首
      _playCompletedHandler();
      return Future.error(e);
    }
    if (entity.playUrl == null) {
      return false;
    }

    //设置下标同步
    musicModel!.setCurrentMusic(entity);

    return await loadMusicForUrl(entity.playUrl!);
  }

  ///播放
  Future<bool> play() async {
    if (_audioPlayer == null) {
      return false;
    }
    if (_status == PlayStatus.stop) {
      logger.e("PalyerService play() => 无法播放因为PlayStatus状态是STOP还未加载音乐资源");
      return false;
    }
    if (_audioPlayer?.state != PlayerState.PLAYING) {
      var state = await _audioPlayer!.resume() == 1 ? true : false;
      if (state) {
        _status = PlayStatus.playing;
      } else {
        _status = PlayStatus.error;
      }
      return state;
    }
    return false;
  }

  ///暂停
  Future<bool> puase() async {
    if (_audioPlayer == null) {
      return false;
    }
    if (_audioPlayer?.state != PlayerState.PLAYING) {
      return true;
    }
    var state = await _audioPlayer!.pause() == 1 ? true : false;
    if (state) {
      _status = PlayStatus.paused;
    } else {
      _status = PlayStatus.error;
    }
    return state;
  }

  ///停止
  Future<bool> stop() async {
    if (_audioPlayer == null) {
      return false;
    }
    var res = await _audioPlayer!.stop() == 1 ? true : false;
    if (res) {
      position = Duration.zero;
      this.playState = PlayStatus.stop;
      AudioServiceBackground.setState(
          processingState: AudioProcessingState.stopped);
    } else {
      logger.e("PlayerService stop() ==> 失败");
      this.playState = PlayStatus.error;
    }
    return res;
  }

  ///跳转到
  Future<bool> seekTo(Duration duration) async {
    if (_audioPlayer == null) {
      return false;
    }
    if (_audioPlayer?.state != PlayerState.PLAYING) {
      return false;
    }
    return await _audioPlayer!.seek(duration) == 1 ? true : false;
  }

  ///加载歌词
  Future<List<Lyric>?> loadLyric(String uuid) async {
    var music = musicModel!.findByUuid(uuid);
    if (music == null) {
      return null;
    }
    //加载歌词
    if (music.lrc != null && music.lrc!.isNotEmpty) {
      return musicServiceProviderMange
          .getSupportProvider(music.source)
          .first
          .formatLyric(music.lrc!);
    }
    try {
      String lrc = await musicServiceProviderMange
          .getSupportProvider(music.source)
          .first
          .getLyric(music);

      //保存到数据库
      musicModel!.save();
      return musicServiceProviderMange
          .getSupportProvider(music.source)
          .first
          .formatLyric(lrc);
    } catch (e) {
      logger.e("下载歌词失败:=====>", e);
      return null;
    }
  }

  ///初始化监听器
  initListener() {
    if (_audioPlayer == null) {
      return;
    }

    ///播放进度
    _audioPlayer!.onAudioPositionChanged.listen((Duration p) {
      position = p;
      var music = _playListModel!.getCurrentMusicEntity();
      if (music != null) {
        AudioServiceBackground.sendCustomEvent(
            PlayerPositionChangedEvent(p, music));
      }
    });
    //播放状态
    _audioPlayer!.onPlayerStateChanged.listen((PlayerState s) {
      logger.i("播放状态: $s");
      PlayStatus status = PlayStatus.stop;
      var music = _playListModel!.getCurrentMusicEntity();
      switch (s) {
        case PlayerState.PAUSED:
          status = PlayStatus.paused;
          break;
        case PlayerState.PLAYING:
          status = PlayStatus.playing;
          break;
        case PlayerState.STOPPED:
          status = PlayStatus.stop;
          AudioServiceBackground.setState(
              processingState: AudioProcessingState.stopped);
          break;
        case PlayerState.COMPLETED:
          status = PlayStatus.completed;
          position = Duration.zero;
          _playCompletedHandler();
          AudioServiceBackground.setState(
              processingState: AudioProcessingState.completed);
          //Check检查播放完成了但是和实际时长差距很大就可能是试听音乐
          if (music != null) {
            int min = 30;
            int diffce = (music.duration.inSeconds - this.position.inSeconds);
            if (diffce > min) {
              ToastUtil.show(msg: "此音乐可能是十几秒的试听音乐", length: Toast.LENGTH_LONG);
            }
          }
          break;
      }
      if (music != null) {
        AudioServiceBackground.sendCustomEvent(
            PlayerChangeEvent(status, music));
      }
    });

    _audioPlayer!.onPlayerError.listen((msg) {
      logger.e("播放出现异常: $msg");
      var music = _playListModel!.getCurrentMusicEntity();
      if (music != null) {
        AudioServiceBackground.sendCustomEvent(PlayerErrorEvent(msg, music));
      }
      AudioServiceBackground.setState(
          processingState: AudioProcessingState.error);
    });
  }

  ///播放完成直接自动进行下一首的逻辑操作
  void _playCompletedHandler() async {
    //记录错误的次数
    await this.stop();
    Map<String, int> errorMap = Map();
    //最大错误的次数
    int errorMax = 3;
    while (musicModel!.next()) {
      var music = musicModel!.getCurrentMusicEntity();
      if (music == null) {
        continue;
      }
      if (await this.loadMusic(music)) {
        //加载成功直接播放
        backageTask.onPlay();
        break;
      } else {
        logger.e("自动播放下一首音乐LoadMusic发送错误:$music");
        //记录错误次数
        errorMap.update(
          music.uuid!,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        //如果超过最大错误次数 直接结束循环
        if (errorMap[music.uuid!]! > errorMax) {
          logger.e("超过错误最大次数=$music 错误次数=${errorMap[music.uuid!]!}");
          break;
        }
        continue;
      }
    }
  }

  ///销毁示例释放资源
  Future<void> dispose() async {
    _status = PlayStatus.stop;
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    await _db.close();
  }
}
