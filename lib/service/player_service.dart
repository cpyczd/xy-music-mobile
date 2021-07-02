/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 18:22:11
 * @LastEditTime: 2021-07-02 17:10:19
 */

import 'package:event_bus/event_bus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:xy_music_mobile/common/event/player/index.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/player_list_model.dart';

import 'base_music_service.dart';

///播放服务
class PlayerService {
  final Logger _logger = log;

  EventBus _musicEventBus = EventBus();

  ///播放列表
  PlayerListModel? _playerListModel;

  AudioPlayer? _audioPlayer;

  ///播放状态
  PlayStatus _status = PlayStatus.stop;

  PlayStatus get playState => _status;

  EventBus get bus => _musicEventBus;

  PlayerListModel? get musicModel => _playerListModel;

  AudioPlayer get player => _audioPlayer!;

  PlayerService() {
    //初始化播放列表
    _audioPlayer = AudioPlayer();

    initListener();
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
    // var mediaList = _playerListModel!.musicList
    //     .map((item) => MediaItem(
    //           id: item.songmId!,
    //           album: item.albumName ?? "-",
    //           title: item.songName,
    //           artist: item.singer,
    //           duration: Duration(microseconds: item.duration),
    //           // artUri: Uri.http(item.picImage ?? "", "")
    //         ))
    //     .toList();
    // AudioServiceBackground.setQueue(mediaList);
  }

  ///加载音乐
  Future<bool> loadMusicForUrl(String url) async {
    _logger.d("loadMusicForUrl :{ $url }");
    try {
      await _audioPlayer!.setUrl(url);
      _status = PlayStatus.ready;
      return true;
    } on PlayerException catch (e) {
      // iOS/macOS: maps to NSError.code
      // Android: maps to ExoPlayerException.type
      // Web: maps to MediaError.code
      _logger.e("Error code: ${e.code}");
      // iOS/macOS: maps to NSError.localizedDescription
      // Android: maps to ExoPlaybackException.getMessage()
      // Web: a generic message
      _logger.e("Error message: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      // This call was interrupted since another audio source was loaded or the
      // player was stopped or disposed before this audio source could complete
      // loading.
      _logger.e("Connection aborted: ${e.message}");
    } catch (e) {
      // Fallback for all errors
      _logger.e(e);
    }
    return false;
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
    if (!_audioPlayer!.playing) {
      try {
        await _audioPlayer!.play();
        _status = PlayStatus.playing;
      } catch (e) {
        _status = PlayStatus.error;
        _logger.e("play exception", e);
        return false;
      }
    }
    return true;
  }

  ///暂停
  Future<bool> puase() async {
    if (_audioPlayer == null) {
      return false;
    }
    if (!_audioPlayer!.playing) {
      return true;
    }
    try {
      await _audioPlayer!.pause();
      _status = PlayStatus.playing;
    } catch (e) {
      _status = PlayStatus.error;
      _logger.e("puase exception", e);
      return false;
    }
    return true;
  }

  ///初始化监听器
  initListener() {
    if (_audioPlayer == null) {
      return;
    }

    _audioPlayer!.playerStateStream.listen((state) {
      // if (state.playing) ... else ...
      switch (state.processingState) {
        case ProcessingState.idle:
          //空闲
          break;
        case ProcessingState.loading:
          //loading加载
          break;
        case ProcessingState.buffering:
          //缓冲中
          break;
        case ProcessingState.ready:
          //准备好了
          break;
        case ProcessingState.completed:
          //播放完成
          _logger.i("播放完成");
          _musicEventBus.fire(
              PlayerCompletionEvent(_playerListModel!.getCurrentMusicEntity()));
          break;
      }
    });

    _audioPlayer!.durationStream.listen((event) {
      if (event != null) {
        _logger.d("durationStream : $event");
        _musicEventBus.fire(new PlayerPositionChangedEvent(
            event, _playerListModel!.getCurrentMusicEntity()));
      }
    });
  }

  ///销毁示例释放资源
  Future<void> dispose() async {
    _status = PlayStatus.stop;
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
  }
}
