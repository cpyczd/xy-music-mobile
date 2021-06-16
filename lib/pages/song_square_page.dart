/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:26:24
 * @LastEditTime: 2021-06-16 23:17:01
 */
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/text_icon_button.dart';

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

  Widget _createBtnAction() {
    return SliverGrid(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        delegate: SliverChildListDelegate([
          TextIconButton(
              icon: Icon(
                Icons.all_inbox_sharp,
                color: Color(AppTheme.getCurrentTheme().primaryColor),
              ),
              text: "全部歌单"),
          TextIconButton(
              icon: Icon(Icons.input_outlined,
                  color: Color(AppTheme.getCurrentTheme().primaryColor)),
              text: "导入外部歌单"),
          TextIconButton(
              icon: Icon(Icons.settings,
                  color: Color(AppTheme.getCurrentTheme().primaryColor)),
              text: "推荐管理"),
        ]));
  }

  ///构建顶部搜索框
  Widget _searchWidget() {
    return GestureDetector(
      onTap: () => Application.navigateToIos(context, "/search"),
      child: Container(
        width: double.infinity,
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 22),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 1.0), //阴影xy轴偏移量
              blurRadius: 1.0, //阴影模糊程度
              spreadRadius: 1.0 //阴影扩散程度
              )
        ], color: Colors.white, borderRadius: BorderRadius.circular(22)),
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
      _createBtnAction(),
      SliverPadding(
        padding: EdgeInsets.only(bottom: 20),
        sliver: _createSuqareWidgetItem(
            title: "网易最热",
            source: MusicSourceConstant.wy,
            sortId: "hot",
            tagId: "华语"),
      ),
      SliverPadding(
          padding: EdgeInsets.only(bottom: 20),
          sliver: _createSuqareWidgetItem(
              title: "酷狗推荐", source: MusicSourceConstant.kg, sortId: "5")),
      SliverPadding(
        padding: EdgeInsets.only(bottom: 20),
        sliver: _createSuqareWidgetItem(
            title: "酷狗最热", source: MusicSourceConstant.kg, sortId: "6"),
      )
    ]);
  }

  ///创建一个Sliver
  Widget _createSuqareWidgetItem(
      {required String title,
      required MusicSourceConstant source,
      String? sortId,
      String? tagId,
      VoidCallback? moreCallBack,
      GestureTapCallback? clickItemCallBack}) {
    var sort = sortId == null ? null : SongSquareSort(id: sortId, name: "");

    var tag = tagId == null
        ? null
        : SongSqurareTagItem(id: tagId, name: "", parentName: "", parentId: "");
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
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            TextButton(
              child: Text("更多"),
              onPressed: moreCallBack,
            ),
          ],
        ),
      ),
      sliver: FutureBuilder<List<SongSquareInfo>>(
        future: SquareServiceProviderMange.getSupportProvider(source)
            .first
            .getSongSquareInfoList(sort: sort, tag: tag),
        builder: (context, snapshot) {
          late List<SongSquareInfo> list;
          int index = 0;
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            list = snapshot.data!.sublist(
                0, snapshot.data!.length < 4 ? snapshot.data!.length : 4);
            index = list.length;
          }
          return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 20),
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                var item = list[index];
                return GestureDetector(
                  onTap: clickItemCallBack,
                  child: Container(
                    width: 131,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: item.img,
                            fit: BoxFit.cover,
                          ),
                        )),
                        Padding(
                          padding: EdgeInsets.only(top: 6, left: 10, right: 10),
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color.fromRGBO(7, 18, 23, 1),
                                fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }, childCount: index));
        },
      ),
    );
  }
}
