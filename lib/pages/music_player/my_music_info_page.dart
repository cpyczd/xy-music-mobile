/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-29 21:01:25
 * @LastEditTime: 2021-06-30 00:18:05
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';

///我的音乐歌单详情页
class MyMusicInfoPage extends StatefulWidget {
  const MyMusicInfoPage({Key? key}) : super(key: key);

  @override
  _MyMusicInfoPageState createState() => _MyMusicInfoPageState();
}

class _MyMusicInfoPageState extends State<MyMusicInfoPage> {
  PaletteGenerator? _paletteGenerator;

  String url =
      // "https://imgessl.kugou.com/uploadpic/softhead/240/20210608/20210608172539722.jpg";
      // "https://imgessl.kugou.com/uploadpic/softhead/240/20210602/20210602150924868.jpg";
      "http://p2.music.126.net/EjksfQRGUB2_i0qz-AHOJA==/109951165928359140.jpg?param=140y140";

  @override
  void initState() {
    super.initState();
    PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(url),
            maximumColorCount: 20,
            region: Offset.zero & Size(240, 240),
            size: Size(240, 240))
        .then((value) {
      setState(() {
        _paletteGenerator = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: CustomScrollView(
        slivers: [_topCovert(), _content()],
      )),
    );
  }

  Widget _topCovert() {
    Color textColor =
        (_paletteGenerator?.dominantColor?.color ?? Colors.transparent) ==
                Colors.transparent
            ? Colors.white
            : AppTheme.reversal(
                _paletteGenerator!.dominantColor!.color.value,
              );
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverFadeDelegate(
          contentHeight: 200,
          barHeight: 50,
          barColor: textColor,
          content: Container(
            child: Center(
              child: Text(
                "文字内容哈哈哈哈哈哈",
                style: TextStyle(color: Color(0xffd8dee9)),
              ),
            ),
          ),
          insertTopWidget: [SliverFadeDelegate.vague(url)],
          action: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: textColor,
                )),
          ],
          paddingTop: MediaQuery.of(context).padding.top),
    );
  }

  Widget _content() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return ListTile(
        title: Text("Index$index"),
      );
    }, childCount: 50));
  }
}
