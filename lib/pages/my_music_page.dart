/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:25:27
 * @LastEditTime: 2021-06-28 16:02:47
 */
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';

class MyMusicPage extends StatefulWidget {
  MyMusicPage({Key? key}) : super(key: key);

  @override
  _MyMusicPageState createState() => _MyMusicPageState();
}

class _MyMusicPageState extends State<MyMusicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: CustomScrollView(
          slivers: [_headMenu(), _mySquare(), _myCollect()],
        ),
      ),
    );
  }

  Widget _headMenu() {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        padding: EdgeInsets.only(left: 30, right: 30, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headMenuItem(0xe681, "本地下载", 10),
            _headMenuItem(0xe603, "我的收藏", 5),
            _headMenuItem(0xe605, "最近播放", 26),
          ],
        ),
      ),
    );
  }

  Widget _headMenuItem(int iconHex16, String title, int count,
      {GestureTapCallback? callback}) {
    return GestureDetector(
      onTap: callback,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconFont(hex16: iconHex16, size: 30),
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Text(
            "$count",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _mySquare() {
    return SliverStickyHeader(
      header: Container(
        padding: EdgeInsets.all(13),
        color: Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "自建歌单",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Expanded(child: SizedBox()),
            IconButton(onPressed: () {}, icon: Icon(Icons.add)),
            IconButton(onPressed: () {}, icon: Icon(Icons.arrow_right)),
          ],
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl:
                    "http://imge.kugou.com/stdmusic/150/20200909/20200909115057861947.jpg",
                fit: BoxFit.cover,
              ),
            ),
            title: Text("我喜欢"),
            subtitle: Text("12首"),
          );
        }, childCount: 5),
      ),
    );
  }
}

Widget _myCollect() {
  return SliverStickyHeader(
    header: Container(
      padding: EdgeInsets.all(13),
      color: Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "收藏歌单",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          Expanded(child: SizedBox()),
          IconButton(onPressed: () {}, icon: Icon(Icons.arrow_right)),
        ],
      ),
    ),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl:
                  "http://imge.kugou.com/stdmusic/150/20200909/20200909115057861947.jpg",
              fit: BoxFit.cover,
            ),
          ),
          title: Text("[怀旧] 90后怀旧单曲合集"),
          subtitle: Text("205首"),
        );
      }, childCount: 5),
    ),
  );
}
