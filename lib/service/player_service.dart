/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 18:22:11
 * @LastEditTime: 2021-07-02 00:28:39
 */

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:event_bus/event_bus.dart';
import 'package:xy_music_mobile/common/event/player/index.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/player_list_model.dart';

///播放服务
class PlayerService {
  EventBus _musicEventBus = EventBus();

  ///播放列表
  PlayerListModel? _playerListModel;

  AudioPlayer? _audioPlayer;

  ///播放状态
  PlayStatus _status = PlayStatus.stop;

  PlayStatus get playState => _status;

  EventBus get bus => _musicEventBus;

  PlayerListModel? get musicModel => _playerListModel;

  PlayerService() {
    //初始化播放列表
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
          duration: 133998,
          durationStr: "02:13",
          picImage:
              "https://p2.music.126.net/wds8BOwCnqiCF9ZX6yWGOA==/109951166004556685.jpg",
          originData: {})
    ]);

    var mediaList = _playerListModel!.musicList
        .map((item) => MediaItem(
              id: item.songmId!,
              album: item.albumName ?? "-",
              title: item.songName,
              artist: item.singer,
              duration: Duration(microseconds: item.duration),
              // artUri: Uri.http(item.picImage ?? "", "")
            ))
        .toList();
    AudioServiceBackground.setQueue(mediaList);
  }

  ///加载音乐
  Future<bool> loadMusicForUrl(String url) async {
    await dispose();
    _status = PlayStatus.loading;
    _audioPlayer = AudioPlayer();
    bool s = await _audioPlayer!.setUrl(url) == 1 ? true : false;
    if (s) {
      _status = PlayStatus.ready;
      initListener();
    } else {
      _status = PlayStatus.error;
    }
    return s;
  }

  ///加载音乐 根据音乐数据Model
  Future<bool> loadMusic(MusicEntity entity) async {
    var service =
        musicServiceProviderMange.getSupportProvider(entity.source).first;
    await service.getMusicPlayUrl(entity);
    if (entity.playUrl == null) {
      return false;
    }

    return await loadMusicForUrl(entity.playUrl!);
  }

  ///播放
  Future<bool> play() async {
    if (_audioPlayer == null) {
      return false;
    }
    if (_status != PlayStatus.ready) {
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

  ///初始化监听器
  initListener() {
    if (_audioPlayer == null) {
      return;
    }

    ///播放进度
    _audioPlayer!.onAudioPositionChanged.listen((Duration p) {
      // log.i("当前播放进度: $p");
      _musicEventBus.fire(new PlayerPositionChangedEvent(
          p, _playerListModel!.getCurrentMusicEntity()));
    });
    //播放状态
    _audioPlayer!.onPlayerStateChanged.listen((PlayerState s) {
      log.i("播放状态: $s");
    });
    _audioPlayer!.onPlayerCompletion.listen((event) {
      log.i("播放完成");
      _musicEventBus.fire(
          PlayerCompletionEvent(_playerListModel!.getCurrentMusicEntity()));
    });
    _audioPlayer!.onPlayerError.listen((msg) {
      log.e("播放出现异常: $msg");
      _musicEventBus.fire(
          PlayerErrorEvent(msg, _playerListModel!.getCurrentMusicEntity()));
    });
  }

  ///销毁示例释放资源
  Future<void> dispose() async {
    _status = PlayStatus.stop;
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
  }
}
