import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/util/stream_util.dart';

/*
 * @Description: 歌单详情歌曲页面
 * @Author: cpyczd
 * @Date: 2021-06-18 4:05 下午
 * @LastEditTime: 2021-06-21 18:00:49
 */
class SquareInfoPage extends StatefulWidget {
  final SongSquareInfo info;

  SquareInfoPage({Key? key, required this.info}) : super(key: key);

  @override
  _SquareInfoPageState createState() => _SquareInfoPageState();
}

class _SquareInfoPageState extends State<SquareInfoPage> with MultDataLine {
  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                //appbar显示
                pinned: false,
                floating: false,
                snap: false,
                forceElevated: false,
                //ture 状态栏下方，false不要状态栏
                primary: false,
                expandedHeight: 400,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const <StretchMode>[
                    // StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle,
                  ],
                  // title: Text(widget.info.name),
                  background: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Column(
                      children: [_topBarInfo(), _action()],
                    ),
                  ),
                ),
                // bottom: PreferredSize(
                //   child: Container(
                //       height: 100,
                //       width: double.infinity,
                //       child: Center(
                //         child: Text(
                //           "我的选项",
                //           style: TextStyle(color: Colors.black, fontSize: 16),
                //         ),
                //       ),
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.only(
                //               topLeft: Radius.circular(15),
                //               topRight: Radius.circular(15)),
                //           color: Colors.white)),
                //   preferredSize: Size(100, 20),
                // ),
              )
            ];
          },
          body: _infoList(),
        ),
      ),
    );
  }

  Widget _topBarInfo() {
    var ordinaryStyle = TextStyle(fontSize: 14);
    return Container(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BackButton(),
            Container(
              margin: EdgeInsets.only(top: 20),
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                        imageUrl: widget.info.img, fit: BoxFit.cover),
                  )),
                  SizedBox.fromSize(size: Size.fromWidth(20)),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.info.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.reversal(AppTheme.getCurrentTheme()
                                .scaffoldBackgroundColor),
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "作者: ${widget.info.author}",
                        style: ordinaryStyle,
                      ),
                      Text("评分: ${widget.info.grade ?? '暂无'}",
                          style: ordinaryStyle),
                      Text("播放量: ${widget.info.playCount}",
                          style: ordinaryStyle),
                      // Text("收藏量:${widget.info.collectCount}"),
                      // Text("时间:${widget.info.time}"),
                    ],
                  ))
                ],
              ),
            ),
            SizedBox.fromSize(
              size: Size.fromHeight(20),
            ),
            Expanded(
              child: Text(
                widget.info.desc ?? '暂无介绍',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.reversal(
                      AppTheme.getCurrentTheme().scaffoldBackgroundColor),
                ),
              ),
            )
          ],
        ));
  }

  Widget _action() {
    return Container();
  }

  Widget _infoList() {
    return Container(
        child: ListView.builder(
            itemCount: 20,
            itemBuilder: (c, i) {
              return ListTile(title: Text("Item:$i"));
            }));
  }
}
