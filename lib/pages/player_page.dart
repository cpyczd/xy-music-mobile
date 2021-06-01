/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 21:07:33
 * @LastEditTime: 2021-06-01 23:19:19
 */
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/util/stream_util.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with MultDataLine {
  final String _startTimeKey = "startTimeKey";
  final String _endTimeKey = "endTimeKey";
  final String _controll = "Controll";

  @override
  void dispose() {
    dataLineDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              new Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new NetworkImage(
                        "http://imge.kugou.com/stdmusic/150/20150720/20150720210642744945.jpg"),
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(
                      Colors.black,
                      BlendMode.overlay,
                    ),
                  ),
                ),
              ),
              Container(
                  child: new BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Opacity(
                  opacity: 0.77,
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.black54,
                    ),
                  ),
                ),
              )),
              // ClipRRect(
              //     // make sure we apply clip it properly
              //     child: BackdropFilter(
              //   //背景滤镜
              //   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), //背景模糊化
              //   child: Container(
              //     alignment: Alignment.center,
              //     color: Colors.grey.withOpacity(0.2),
              //   ),
              // )),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    _backWidget(),
                    Expanded(child: Container()),
                    _bottomControll()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ///顶部TopBar
  Widget _backWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BackButton(
            color: Colors.white,
            onPressed: () => Application.router.pop(context),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Text(
              "我们的歌",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ))
      ],
    );
  }

  Widget _bottomControll() {
    return Column(
      children: [
        Row(
          children: [
            getLine<String>(_startTimeKey, initData: "00:00")
                .addObserver((context, data) => Text(
                      data,
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    )),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: getLine(_controll, initData: 0.1)
                        .addObserver((context, data) => Slider(
                              value: data,
                              inactiveColor: Colors.grey.shade600,
                              activeColor: Colors.white,
                              onChanged: (double value) {
                                getLine(_controll).inner.add(value);
                              },
                            )))),
            getLine<String>(_startTimeKey, initData: "00:00")
                .addObserver((context, data) => Text(
                      data,
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    )),
          ],
        )
      ],
    );
  }
}
