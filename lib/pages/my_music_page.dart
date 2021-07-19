/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:25:27
 * @LastEditTime: 2021-07-16 22:03:10
 */
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/common/event/group/group_event_constant.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_order_entity.dart';
import 'package:xy_music_mobile/service/song_group/song_group_service.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';

class MyMusicPage extends StatefulWidget {
  MyMusicPage({Key? key}) : super(key: key);

  @override
  _MyMusicPageState createState() => _MyMusicPageState();
}

class _MyMusicPageState extends State<MyMusicPage> with MultDataLine {
  ///歌单列表Stream Key
  static const _KEY_GROUP_LIST = "_KEY_ORDERS_LIST";

  //歌单服务
  final SongGroupService groupService = SongGroupService();

  StreamSubscription? _groupEventListener;

  @override
  void initState() {
    super.initState();
    //初始化Bus监听器
    _groupEventListener =
        Application.eventBus.on<GroupEventEnum>().listen((event) {
      if (event == GroupEventEnum.MUSIC_LIST_CHANGE) {
        _loadGroupLists();
      }
    });
    Future.delayed(Duration.zero).then((value) {
      _loadGroupLists();
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    _groupEventListener?.cancel();
    super.dispose();
  }

  ///加载Group列表
  void _loadGroupLists() {
    groupService.findGroupAll().then(
        (value) => getLine<List<SongGroup>>(_KEY_GROUP_LIST).setData(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: CustomScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _headMenu(), _mySquare(),
            // _myCollect()
          ],
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
              "我的歌单",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Expanded(child: SizedBox()),
            IconButton(
                onPressed: _clickHandleCreateGroup, icon: Icon(Icons.add)),
            // IconButton(onPressed: () {}, icon: Icon(Icons.arrow_right)),
          ],
        ),
      ),
      sliver: getLine<List<SongGroup>>(_KEY_GROUP_LIST, initData: [])
          .addObserver((context, pack) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  SongGroup group = pack.data![index];
                  bool isLikeGroup =
                      (group.id! == SongGroupService.getLikeId());

                  return Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      onTap: () {
                        Application.navigateToIos(context, "/myMusicInfo",
                            params: group.id!);
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: StringUtils.isNotBlank(group.coverImage)
                            ? CachedNetworkImage(
                                imageUrl: group.coverImage!,
                                fit: BoxFit.cover,
                                height: 50,
                                width: 50,
                              )
                            : Image.asset("assets/img/group_cover.png"),
                      ),
                      title: Text(group.groupName),
                      subtitle: Text("${group.musicCount}首"),
                      trailing: !isLikeGroup
                          ? IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(25),
                                            topRight: Radius.circular(25))),
                                    builder: (BuildContext context) {
                                      return ListView(
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 30,
                                            bottom: 10),
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              Navigator.pop(context);
                                              _clickHandleEditGroup(group);
                                            },
                                            title: Text("编辑"),
                                            leading: Icon(Icons.edit),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              _clickHandleDeleteGroup(group);
                                              Navigator.pop(context);
                                            },
                                            title: Text("删除"),
                                            leading: Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(Icons.more_vert),
                            )
                          : null,
                    ),
                  );
                }, childCount: pack.data!.length),
              )),
    );
  }

  ///我的收藏
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
          return Container(
            height: 50,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
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
              // trailing: IconButton(
              //   onPressed: () {},
              //   icon: Icon(Icons.more_vert),
              // ),
            ),
          );
        }, childCount: 5),
      ),
    );
  }

  ///点击创建歌单
  void _clickHandleCreateGroup() {
    DialogUtil.showInputDialog(context, placeholder: "请输入歌单名称", title: "创建歌单",
        call: (val) {
      if (val.isEmpty) {
        ToastUtil.show(msg: "请输入完整");
      } else {
        groupService
            .createGroup(SongGroup(groupName: val.trim()))
            .then((value) {
          ToastUtil.show(msg: "创建成功");
          _loadGroupLists();
        });
        Navigator.pop(context);
      }
    });
  }

  ///编辑歌单
  void _clickHandleEditGroup(SongGroup group) {
    DialogUtil.showInputDialog(context,
        placeholder: "请输入新歌单名称",
        title: "修改歌单",
        initVal: group.groupName, call: (val) {
      if (val.isEmpty) {
        ToastUtil.show(msg: "请输入完整");
      } else {
        group.groupName = val.trim();
        groupService.updateGroup(group).then((value) {
          ToastUtil.show(msg: "更新成功");
          _loadGroupLists();
        });
        Navigator.pop(context);
      }
    });
  }

  ///删除歌单
  void _clickHandleDeleteGroup(SongGroup group) {
    DialogUtil.showConfirmDialog(context, "您确定要删除此歌单吗,删除后您歌单内的音乐也将删除.此操作不可恢复",
        ok: () {
      groupService.deleteGroupById(group.id!).then((value) {
        ToastUtil.show(msg: "删除成功");
        _loadGroupLists();
      });
    });
  }
}
