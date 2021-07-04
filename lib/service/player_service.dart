/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 18:22:11
 * @LastEditTime: 2021-07-04 22:11:47
 */

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:xy_music_mobile/common/event/player/index.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/player_list_model.dart';
import 'package:xy_music_mobile/util/index.dart';

import 'audio_service_task.dart';

///播放服务
class PlayerService {
  final AudioPlayerBackageTask backageTask;

  ///播放列表
  PlayerListModel? _playerListModel;

  AudioPlayer? _audioPlayer;

  final String _playerInstanceId = "xy-music-play-id";

  ///播放状态
  PlayStatus _status = PlayStatus.stop;

  PlayStatus get playState => this._status;

  set playState(PlayStatus status) => this._status = status;

  PlayerListModel? get musicModel => _playerListModel;

  ///当前播放的进度
  Duration position = Duration.zero;

  PlayerService(this.backageTask) {
    //初始化播放列表
    _audioPlayer =
        AudioPlayer(mode: PlayerMode.MEDIA_PLAYER, playerId: _playerInstanceId);
    loadPalyList();
  }

  ///加载播放列表
  void loadPalyList() {
    //从Hive进行加载
    _playerListModel = PlayerListModel(musicList: [
      MusicEntity(
          songmId: "1847256510",
          albumId: "127828248",
          albumName: "不该用情",
          singer: "叫莫姐姐",
          songName: "不该用情",
          songnameOriginal: null,
          source: MusicSourceConstant.wy,
          duration: Duration(milliseconds: 133998),
          durationStr: "02:13",
          picImage:
              // "https://p2.music.126.net/wds8BOwCnqiCF9ZX6yWGOA==/109951166004556685.jpg",
              "http://pic3.zhimg.com/50/v2-c524149a6e4126baf8a64cecf8eb2db3_hd.jpg",
          originData: {})
    ]);
    this.syncQueue();
  }

  ///同步播放队列
  void syncQueue() {
    var mediaList = _playerListModel!.musicList
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
    // await dispose();
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
      await service.getMusicPlayUrl(entity);
    } catch (e) {
      log.e("PlayerService => 音乐解析失败");
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
      log.e("PalyerService play() => 无法播放因为PlayStatus状态是STOP");
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
      log.e("PlayerService stop() ==> 失败");
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

  ///初始化监听器
  initListener() {
    if (_audioPlayer == null) {
      return;
    }

    ///播放进度
    _audioPlayer!.onAudioPositionChanged.listen((Duration p) {
      position = p;
      AudioServiceBackground.sendCustomEvent(PlayerPositionChangedEvent(
          p, _playerListModel!.getCurrentMusicEntity()!));
    });
    //播放状态
    _audioPlayer!.onPlayerStateChanged.listen((PlayerState s) {
      log.i("播放状态: $s");
      PlayStatus status = PlayStatus.stop;
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
          break;
      }
      AudioServiceBackground.sendCustomEvent(PlayerChangeEvent(
          status, _playerListModel!.getCurrentMusicEntity()!));
    });

    _audioPlayer!.onPlayerError.listen((msg) {
      log.e("播放出现异常: $msg");
      AudioServiceBackground.sendCustomEvent(
          PlayerErrorEvent(msg, _playerListModel!.getCurrentMusicEntity()!));
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
        log.e("自动播放下一首音乐LoadMusic发送错误:$music");
        //记录错误次数
        errorMap.update(
          music.uuid!,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        //如果超过最大错误次数 直接结束循环
        if (errorMap[music.uuid!]! > errorMax) {
          log.e("超过错误最大次数=$music 错误次数=${errorMap[music.uuid!]!}");
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
  }
}
