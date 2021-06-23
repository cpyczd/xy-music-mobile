import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/util/stream_util.dart';

/*
 * @Description: 歌单详情歌曲页面
 * @Author: cpyczd
 * @Date: 2021-06-18 4:05 下午
 * @LastEditTime: 2021-06-23 16:08:44
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
      backgroundColor:
          Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //修改颜色
        ),
        centerTitle: true,
        title: Text(
          widget.info.name,
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _topBarInfo(),
              ),
              _infoList()
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBarInfo() {
    var ordinaryStyle = TextStyle(fontSize: 14, color: Colors.white);
    return Container(
      height: 200,
      color: Colors.white,
      child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(widget.info.img),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              child: Hero(
                tag: "heroTag",
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: widget.info.img,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                                top: 5,
                                left: 5,
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.5, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.5),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: RichText(
                                        text: TextSpan(
                                            style: TextStyle(fontSize: 10),
                                            children: [
                                          WidgetSpan(
                                              child: Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 10,
                                          )),
                                          TextSpan(text: widget.info.playCount)
                                        ]))))
                          ],
                        ),
                      ),
                      SizedBox.fromSize(size: Size.fromWidth(20)),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.info.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            "作者: ${widget.info.author}",
                            style: ordinaryStyle,
                          ),
                          widget.info.desc != null &&
                                  widget.info.desc!.isNotEmpty
                              ? Expanded(
                                  child: GestureDetector(
                                  onTap: () {
                                    log.d("点击了描述");
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        widget.info.desc ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: ordinaryStyle,
                                      )),
                                      Icon(
                                        Icons.arrow_right,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ))
                              : SizedBox.expand()
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _action() {
    return Container();
  }

  Widget _infoList() {
    return SliverStickyHeader(
      overlapsContent: false,
      header: Container(
        height: 60.0,
        color: Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.play_arrow),
                label: Text("播放全部"))
          ],
        ),
      ),
      sliver: SliverList(
          delegate: SliverChildBuilderDelegate((content, index) {
        return Container(
          height: 65,
          color: Colors.primaries[index % Colors.primaries.length],
        );
      }, childCount: 30)),
    );
  }
}
