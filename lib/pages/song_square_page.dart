/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:26:24
 * @LastEditTime: 2021-07-04 21:00:02
 */
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/common/source_constant.dart';
import 'package:xy_music_mobile/pages/square/square_list_page.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';
import 'package:xy_music_mobile/view_widget/text_icon_button.dart';

///歌单广场 主页
class SongSquarePage extends StatefulWidget {
  SongSquarePage({Key? key}) : super(key: key);

  @override
  _SongSquarePageState createState() => _SongSquarePageState();
}

class _SongSquarePageState extends State<SongSquarePage> with MultDataLine {
  ///展示的歌单列表配置
  final List<_LoadSquareGroup> _groups = [
    _LoadSquareGroup(
        name: "网易最热",
        source: MusicSourceConstant.wy,
        sortId: "hot",
        tagId: "华语"),
    _LoadSquareGroup(
      name: "酷狗推荐",
      source: MusicSourceConstant.kg,
      sortId: "5",
    ),
    _LoadSquareGroup(name: "酷狗最热", source: MusicSourceConstant.kg, sortId: "6"),
  ];

  ///Grid每组展示的个数
  final int _groupItemSize = 6;

  late BuildContext _context;

  @override
  void initState() {
    log.d("InitState 被调用 =>> SongSquarePage");
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      for (var item in _groups) {
        var sort = item.sortId == null
            ? null
            : SongSquareSort(id: item.sortId!, name: "");

        var tag = item.tagId == null
            ? null
            : SongSqurareTagItem(
                id: item.tagId!, name: "", parentName: "", parentId: "");
        var list = await squareServiceProviderMange
            .getSupportProvider(item.source)
            .first
            .getSongSquareInfoList(sort: sort, tag: tag);
        getLine<List<SongSquareInfo>>(item.source.name)
            .setData(list.take(_groupItemSize).toList());
      }
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: Container(
        child: _squareList(),
      ),
    );
  }

  Widget _createBtnAction() {
    return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 2.5),
        delegate: SliverChildListDelegate([
          TextIconButton(
            // icon: Icon(
            //   Icons.all_inbox_sharp,
            //   color: Color(AppTheme.getCurrentTheme().primaryColor),
            // ),
            icon: svg(name: "gedan"),
            text: "全部歌单",
            onPressed: () =>
                Application.navigateToIos(_context, "/squareListPage"),
          ),
          TextIconButton(
            icon: svg(name: "custom"),
            text: "推荐管理",
            onPressed: () async {
              log.i("停止线程");
              await AudioService.stop();
            },
          ),
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

  ///创建首页Banner
  Widget _createSwiper() {
    return SliverToBoxAdapter(
      child: Container(
        height: 130,
        child: Swiper.children(
          containerHeight: 130,
          containerWidth: double.infinity,
          autoplay: true,
          pagination: SwiperPagination(),
          children: [
            Image.asset(
              "assets/tmp/banner1.jpeg",
              fit: BoxFit.cover,
            ),
            Image.asset(
              "assets/tmp/banner2.jpeg",
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Widget _squareList() {
    return CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          _createSwiper(),
          _createBtnAction(),
        ]..addAll(_groups
            .map((e) => SliverPadding(
                  padding: EdgeInsets.only(bottom: 20, left: 15, right: 15),
                  sliver: _createSquareWidgetItem(e),
                ))
            .toList()));
  }

  ///创建一个Sliver
  Widget _createSquareWidgetItem(_LoadSquareGroup data) {
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
              data.name,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
                onPressed: () {
                  if (data.moreClick != null) {
                    data.moreClick!(context, data);
                  }
                },
                icon: Text("更多"),
                label: Icon(
                  Icons.more_horiz,
                  size: 15,
                ))
          ],
        ),
      ),
      sliver: getLine<List<SongSquareInfo>>(data.source.name, initData: [])
          .addObserver((context, pack) {
        return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 20),
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              var item = pack.data![index];
              return GestureDetector(
                onTap: () {
                  if (data.squareInfoClick != null) {
                    data.squareInfoClick!(context, item);
                  }
                },
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
            }, childCount: pack.data!.length));
      }),
    );
  }
}

typedef void _MoreClickHandler(BuildContext context, _LoadSquareGroup group);

typedef void _SquareInfoClickHandler(BuildContext context, SongSquareInfo info);

class _LoadSquareGroup {
  final String name;

  final MusicSourceConstant source;

  String? sortId;

  String? tagId;

  _MoreClickHandler? moreClick = (context, group) {
    Application.navigateToIos(context, "/squareListPage",
        params: SquareListPageArauments(
            paramsSource: group.source, paramsSort: group.sortId));
  };

  _SquareInfoClickHandler? squareInfoClick = (context, info) {
    // Application.navigateToIos(context, "/squareInfoPage", params: info);
    Application.router.navigateTo(
      context,
      "/squareInfoPage",
      transition: TransitionType.native,
      routeSettings: RouteSettings(arguments: info),
    );
  };

  _LoadSquareGroup({
    required this.name,
    required this.source,
    this.sortId,
    this.tagId,
    _MoreClickHandler? moreClick,
    _SquareInfoClickHandler? squareInfoClick,
  }) {
    if (moreClick != null) {
      this.moreClick = moreClick;
    }
    if (squareInfoClick != null) {
      this.squareInfoClick = squareInfoClick;
    }
  }
}
