/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 22:19:35
 * @LastEditTime: 2021-07-02 16:58:57
 */

import 'package:audio_service/audio_service.dart';
import 'package:logger/logger.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/service/player_service.dart';
import 'package:xy_music_mobile/util/index.dart';

class AudioPlayerBackageTask extends BackgroundAudioTask {
  final Logger logger = log;

  late final PlayerService service;

  AudioPlayerBackageTask() {
    Application.applicationInit();
    HttpUtil.logOpen();
    service = PlayerService();
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    logger.d("onStart params: $params");

    bool state =
        await service.loadMusic(service.musicModel!.getCurrentMusicEntity());
    logger.d("onStart=>loadMusic=>$state");
    return;
  }

  @override
  Future<void> onPlay() async {
    logger.d("onPlay 调用 Response:${await service.play()}");
    // await service.play()
    AudioServiceBackground.setState(
      playing: true,
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
    );
    return super.onPlay();
  }

  @override
  Future<void> onPause() async {
    await service.puase();
    AudioServiceBackground.setState(
      playing: false,
      controls: [
        MediaControl.play,
        MediaControl.stop,
      ],
    );
    return super.onPause();
  }

  @override
  Future<void> onSkipToNext() async {
    var state = service.musicModel!.next();
    if (state) {
      await service.loadMusic(service.musicModel!.getCurrentMusicEntity());
      await service.play();
    }
    return super.onSkipToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    var state = service.musicModel!.previous();
    if (state) {
      await service.loadMusic(service.musicModel!.getCurrentMusicEntity());
      await service.play();
    }
    return super.onSkipToPrevious();
  }

  @override
  Future<void> onStop() async {
    await service.dispose();
    return super.onStop();
  }
}
