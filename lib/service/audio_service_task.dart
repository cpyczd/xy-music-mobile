/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 22:19:35
 * @LastEditTime: 2021-07-03 00:14:48
 */
import 'package:audio_service/audio_service.dart';
import 'package:logger/logger.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/player_constan.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
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

  @override
  Future<void> onSeekTo(Duration position) {
    log.d("onSeekTo: position = $position");
    service.seekTo(position);
    return super.onSeekTo(position);
  }

  @override
  Future<List<MediaItem>> onLoadChildren(String parentMediaId) {
    log.d("onLoadChildren: Params{parentMediaId = $parentMediaId}");
    return Future.value(AudioServiceBackground.queue);
  }

  @override
  Future<void> onStop() async {
    await service.dispose();
    await super.onStop();
    return;
  }
}
