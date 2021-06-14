/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:26:24
 * @LastEditTime: 2021-06-14 12:57:24
 */
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/util/stream_util.dart';

///歌单广场 主页
class SongSquarePage extends StatefulWidget {
  SongSquarePage({Key? key}) : super(key: key);

  @override
  _SongSquarePageState createState() => _SongSquarePageState();
}

class _SongSquarePageState extends State<SongSquarePage> with MultDataLine {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 36),
          child: Column(
            children: [
              _searchWidget(),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(top: 20),
                child: _squareList(),
              ))
            ],
          ),
        ),
      ),
    );
  }

  ///构建顶部搜索框
  Widget _searchWidget() {
    return GestureDetector(
      onTap: () => Application.navigateToIos(context, "/search"),
      child: Container(
        width: double.infinity,
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 22),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                color: Colors.black54,
              ),
              SizedBox.fromSize(
                size: Size.fromWidth(10),
              ),
              Text(
                "歌曲搜索",
                style: TextStyle(color: Colors.black54),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _squareList() {
    return CustomScrollView(slivers: <Widget>[
      // StickyHeader(
      //     header: Container(
      //       child: Text(
      //         "酷狗Top",
      //         style: TextStyle(fontSize: 18, color: Colors.black),
      //       ),
      //     ),
      //     content: SliverList(
      //       delegate: SliverChildBuilderDelegate((content, index) {
      //         return Container(
      //           height: 65,
      //           color: Colors.primaries[index % Colors.primaries.length],
      //         );
      //       }, childCount: 1),
      //     ))
      SliverStickyHeader(
        overlapsContent: false,
        header: Container(
          height: 60.0,
          color: Color.fromRGBO(248, 248, 248, 1),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Header #0',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 3),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              color: Colors.primaries[index % Colors.primaries.length],
            );
          }, childCount: 20),
        ),
      ),
      SliverStickyHeader(
        header: Container(
          height: 60.0,
          color: Colors.lightBlue,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Header #2',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 3),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              color: Colors.primaries[index % Colors.primaries.length],
            );
          }, childCount: 20),
        ),
      ),
      SliverStickyHeader(
        header: Container(
          height: 60.0,
          color: Colors.lightBlue,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Header #1',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 3),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              color: Colors.primaries[index % Colors.primaries.length],
            );
          }, childCount: 20),
        ),
      )
    ]);
  }
}
