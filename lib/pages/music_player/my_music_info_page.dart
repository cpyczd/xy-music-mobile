/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-29 21:01:25
 * @LastEditTime: 2021-07-01 13:50:21
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/util/widget_common.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';

///我的音乐歌单详情页
class MyMusicInfoPage extends StatefulWidget {
  const MyMusicInfoPage({Key? key}) : super(key: key);

  @override
  _MyMusicInfoPageState createState() => _MyMusicInfoPageState();
}

class _MyMusicInfoPageState extends State<MyMusicInfoPage> {
  String url =
      "https://imgessl.kugou.com/uploadpic/softhead/240/20210608/20210608172539722.jpg";
  // "https://imgessl.kugou.com/uploadpic/softhead/240/20210602/20210602150924868.jpg";
  // "http://p2.music.126.net/EjksfQRGUB2_i0qz-AHOJA==/109951165928359140.jpg?param=140y140";

  @override
  void initState() {
    super.initState();
    //设置状态栏的颜色为亮色
    //设置状态栏的颜色
    setUiOverlayStyle(Brightness.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [_topCovert(), _content()],
      )),
    );
  }

  Widget _topCovert() {
    Color textColor = Colors.white;
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverFadeDelegate(
          contentHeight: 150,
          barHeight: 50,
          spacing: 1,
          title: "自建歌单",
          toTopReplaceTitle: "我喜欢的歌单",
          barColor: textColor,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Size.fromWidth(20),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("我喜欢歌单",
                          style: TextStyle(color: textColor, fontSize: 18)),
                      Text("暂无简介",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ))
                ],
              ),
            ),
          ),
          insertTopWidget: [
            SliverFadeDelegate.vague(url, sigmaX: 60, sigmaY: 60)
          ],
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

  ///内容
  Widget _content() {
    return SliverStickyHeader(
      header: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.play_arrow_rounded),
                label: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "播放全部",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                      children: [
                        TextSpan(
                            text: " 12首",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13))
                      ]),
                )),
            IconButton(
              onPressed: () {},
              icon: iconFont(hex16: 0xe624, size: 20),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            )
          ],
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            height: 50,
            margin: EdgeInsets.only(bottom: 7, left: 10, right: 10),
            width: double.infinity,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: iconFont(hex16: 0xe627, size: 20, color: Colors.green),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "下辈子不一定还能遇见你",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "任重",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: iconFont(
                                hex16: 0xe612, size: 20, color: Colors.grey)),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.green,
                              size: 20,
                            )),
                      ],
                    ))
              ],
            ),
          );
        }, childCount: 30),
      ),
    );
  }
}
