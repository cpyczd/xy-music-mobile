/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:25:27
 * @LastEditTime: 2021-05-27 00:13:36
 */
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/view_widget/card_view.dart';

class MyMusicPage extends StatefulWidget {
  MyMusicPage({Key? key}) : super(key: key);

  @override
  _MyMusicPageState createState() => _MyMusicPageState();
}

class _MyMusicPageState extends State<MyMusicPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  " 我的音乐",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700),
                ),
              ),
              widgetCurrentPlayer(),
              SizedBox.fromSize(
                size: Size.fromHeight(13),
              ),
              widgetMyLike(),
              SizedBox.fromSize(
                size: Size.fromHeight(13),
              ),
              widgetMusicCollectForMy()
            ],
          ),
        ),
      ),
    ));
  }

  ///当前播放
  Widget widgetCurrentPlayer() {
    return CardView(
        widget: Container(
      width: double.infinity,
      height: 100,
      child: Center(
        child: Text("当前播放"),
      ),
    ));
  }

  ///我的喜欢
  Widget widgetMyLike() {
    return CardView(
        widget: Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(Icons.headset_rounded),
        ),
        title: Text("我的喜欢"),
        subtitle: Text("32首"),
        trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.play_circle_fill,
              color: Colors.redAccent,
              size: 35,
            )),
      ),
    ));
  }

  ///我的收藏歌单
  Widget widgetMusicCollectForMy() {
    return CardView(
        widget: Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "创建歌单",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ),
              )
            ],
          ),
          Divider(height: 1),
        ]..addAll(List.filled(5, "s")
            .map((e) => Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: ClipOval(
                      child: Image.asset(
                        "assets/tmp/zhuanji.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text("随意收藏"),
                  ),
                ))
            .toList()),
      ),
    ));
  }
}
