/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-29 21:01:25
 * @LastEditTime: 2021-07-15 22:10:57
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_order_entity.dart';
import 'package:xy_music_mobile/service/song_group/song_group_service.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/util/widget_common.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';
import 'package:xy_music_mobile/common/source_constant.dart';

///我的音乐歌单详情页
class MyMusicInfoPage extends StatefulWidget {
  final int groupId;

  const MyMusicInfoPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _MyMusicInfoPageState createState() => _MyMusicInfoPageState();
}

class _MyMusicInfoPageState extends State<MyMusicInfoPage> with MultDataLine {
  static const _KEY_MUSIC = "_KEY_MUSIC";

  SongGroupService groupService = SongGroupService();

  SongGroup? _group;

  @override
  void initState() {
    groupService.findGroupById(widget.groupId).then((value) {
      setState(() {
        _group = value;
      });
    });
    //读取音乐数据
    groupService
        .findAllMusicByGroupId(widget.groupId)
        .then((value) => getLine<List<MusicEntity>>(_KEY_MUSIC).setData(value));

    //设置状态栏的颜色为亮色
    //设置状态栏的颜色
    Future.delayed(Duration.zero)
        .then((value) => setUiOverlayStyle(Brightness.dark));
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
          title: "我的歌单",
          toTopReplaceTitle: _group?.groupName,
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
                    child: StringUtils.isNotBlank(_group?.coverImage)
                        ? CachedNetworkImage(
                            imageUrl: _group!.coverImage!,
                            fit: BoxFit.cover,
                            height: 120,
                            width: 120,
                          )
                        : Image.asset("assets/img/group_cover.png"),
                  ),
                  SizedBox.fromSize(
                    size: Size.fromWidth(20),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_group?.groupName ?? "-",
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
            StringUtils.isNotBlank(_group?.coverImage)
                ? SliverFadeDelegate.vague(_group!.coverImage!,
                    sigmaX: 60, sigmaY: 60)
                : Container(
                    color: Colors.black45,
                  )
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
                            text: " ${_group?.musicCount ?? 0} 首",
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
      sliver: getLine<List<MusicEntity>>(_KEY_MUSIC, initData: [])
          .addObserver((context, pack) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var music = pack.data![index];

                  return Container(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 7, left: 10, right: 10),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Text(
                          "${index + 1}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45),
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
                                  music.songName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  music.singer ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  "来源:${music.source.desc}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 9),
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
                                    onPressed: () => _clickHandleMore(music),
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
                }, childCount: pack.data!.length),
              )),
    );
  }

  ///点击更多的弹出框
  void _clickHandleMore(MusicEntity music) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (BuildContext context) {
          return ListView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(12),
            children: [
              ListTile(
                title: Text("下一首播放"),
                leading: Icon(Icons.edit),
              ),
              ListTile(
                title: Text("收藏到歌单"),
                leading: Icon(
                  Icons.collections,
                ),
              ),
              ListTile(
                title: Text("删除"),
                leading: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
              ),
            ],
          );
        });
  }
}
