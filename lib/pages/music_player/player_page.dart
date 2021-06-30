/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 21:07:33
 * @LastEditTime: 2021-06-30 23:58:35
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with MultDataLine {
  final String _startTimeKey = "startTimeKey";
  final String _endTimeKey = "endTimeKey";
  final String _controll = "Controll";

  PaletteGenerator? _paletteGenerator;

  ///主色调
  Color primaryColor = Color(AppTheme.getCurrentTheme().primaryColor);

  String url =
      "https://imgessl.kugou.com/uploadpic/softhead/240/20210608/20210608172539722.jpg";
  // "https://imgessl.kugou.com/uploadpic/softhead/240/20210602/20210602150924868.jpg";
  // "http://p2.music.126.net/EjksfQRGUB2_i0qz-AHOJA==/109951165928359140.jpg?param=140y140";

  @override
  void initState() {
    super.initState();
    PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(url),
            size: Size(500, 1000), region: Offset.zero & Size(10, 10))
        .then((value) {
      setState(() {
        _paletteGenerator = value;
        if (_paletteGenerator?.dominantColor?.color.value != null) {
          var reversalColor =
              AppTheme.reversal(_paletteGenerator!.dominantColor!.color.value);
          //计算是否接近白色
          var Y = 0.2126 * reversalColor.red +
              0.7152 * reversalColor.green +
              0.0722 * reversalColor.blue;
          primaryColor = Y < 128 ? Colors.black : Colors.white;
        }
      });
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black54,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SliverFadeDelegate.vague(url, sigmaX: 40, sigmaY: 40),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: Column(
                  children: [
                    _backWidget(),
                    Expanded(child: Container()),
                    _bottomControll()
                  ],
                ),
              ),
            )
          ],
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
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: primaryColor,
            ),
            onPressed: () => Application.router.pop(context),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Text(
              "我们的歌",
              style: TextStyle(
                  color: primaryColor,
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
                .addObserver((context, pack) => Text(
                      pack.data!,
                      style: TextStyle(color: primaryColor, fontSize: 10),
                    )),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: getLine(_controll, initData: 0.1)
                        .addObserver((context, pack) => Slider(
                              value: pack.data!,
                              inactiveColor: Colors.grey.shade600,
                              activeColor: Colors.white,
                              onChanged: (double value) {
                                getLine(_controll).setData(value);
                              },
                            )))),
            getLine<String>(_startTimeKey, initData: "00:00")
                .addObserver((context, pack) => Text(
                      pack.data!,
                      style: TextStyle(color: primaryColor, fontSize: 10),
                    )),
          ],
        )
      ],
    );
  }
}
