/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:39:29
 * @LastEditTime: 2021-07-05 20:16:21
 */
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/store_config.dart';
import 'package:xy_music_mobile/model/play_list_model.dart';
import 'package:xy_music_mobile/service/audio_service_task.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    log.d("InitState 被调用 =>> SettingPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _createButtn("停止Task线程", () async {
              log.d("停止线程...");
              await AudioService.stop();
            }, color: Colors.redAccent),
            _createButtn("清空音乐数据库数据", () async {
              final String _boxDb = "xy-music-play-storeDb";
              log.d("清空MusicBox数据...");
              Box<PlayListModel> box =
                  await Store.openBox<PlayListModel>(_boxDb);
              await box.clear();
              await box.close();
            }, color: Colors.redAccent),
            _createButtn("打印音乐数据库数据", () async {
              final String _boxDb = "xy-music-play-storeDb";
              final String _boxModelKey = "xy-music-play-storeDb-key-model1";
              log.d("打印Music Box数据...");
              Box<PlayListModel> box =
                  await Store.openBox<PlayListModel>(_boxDb);
              var data = box.get(_boxModelKey);
              log.i(
                  "Box数据:=====> currentIndex:${data!.currentIndex},mode:${data.mode},musciLength:${data.musicList.length}");
              log.i("Box数据:MusicItems=====>\n${data.musicList.map((e) => {
                    'songName': e.songName,
                    'uuid': e.uuid,
                    'playUrl': e.playUrl,
                    'picImage': e.picImage,
                  }).join('\n').toString()}");
              await box.close();
            }),
            _createButtn("重新Reload音乐数据", () async {
              log.d("重新reload音乐数据...");
              await PlayerTaskHelper.reloadMusic();
              await PlayerTaskHelper.syncQueue();
            }, color: Colors.orangeAccent),
            _createButtn("打印当前队列数据", () async {
              log.d("打印当前队列数据...");
              var musics = await PlayerTaskHelper.getMusicList();
              var queue = AudioService.queue;
              var musicInfo = musics
                  .map((e) => {"songName": e.songName, "uuid": e.uuid})
                  .toString();
              var queueInfo = queue!
                  .map((e) => {"id": e.id, "songName": e.title})
                  .toString();
              log.i(
                  "MusicsEntitys:{ length=${musics.length} 、data = $musicInfo}");
              log.i("Queue:{ length=${queue.length} 、data = $queueInfo}");
              log.d("打印当前队列数据====>结束");
            }),
          ],
        ),
      ),
    ));
  }

  Widget _createButtn(String text, VoidCallback onTap,
      {Color color = Colors.lightBlue}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        color: color,
        pressedOpacity: .5,
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(fontSize: 13.5),
        ),
      ),
    );
  }
}
