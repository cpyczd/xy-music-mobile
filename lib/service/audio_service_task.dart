/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 22:19:35
 * @LastEditTime: 2021-07-02 00:25:53
 */

import 'package:audio_service/audio_service.dart';
import 'package:xy_music_mobile/service/player_service.dart';

class AudioPlayerBackageTask extends BackgroundAudioTask {
  final PlayerService service;

  AudioPlayerBackageTask(this.service);

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    print("onStart: params: $params");
    // var mediaList = service.musicModel!.musicList
    //     .map((item) => MediaItem(
    //         id: item.playUrl!,
    //         album: item.albumName ?? "-",
    //         title: item.songName,
    //         artist: item.singer,
    //         duration: Duration(microseconds: item.duration),
    //         artUri: Uri.http(item.picImage ?? "", "")))
    //     .toList();
    // AudioServiceBackground.setQueue(mediaList);
    print(AudioServiceBackground.queue);
    AudioServiceBackground.setMediaItem(AudioServiceBackground.queue!.first);
    // await service.play();
    AudioServiceBackground.setState(
      playing: true,
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
    );
    return;
  }

  @override
  Future<void> onPlay() async {
    print("onPlay 调用");
    await service.play();
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
}
