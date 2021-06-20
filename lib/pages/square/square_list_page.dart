import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/application.dart';

import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';

/*
 * @Description: 歌单页
 * @Author: chenzedeng
 * @Date: 2021-06-18 16:12:23
 * @LastEditTime: 2021-06-20 16:26:31
 */
class SquareListPage extends StatefulWidget {
  final SquareListPageArauments? arauments;

  SquareListPage({Key? key, this.arauments}) : super(key: key);

  @override
  _SquareListPageState createState() => _SquareListPageState();
}

class _SquareListPageState extends State<SquareListPage>
    with MultDataLine, TickerProviderStateMixin {
  late OverlayEntry _overlayEntry;

  late BuildContext _context;

  GlobalKey _globalKey = GlobalKey();

  ///源
  MusicSourceConstant _source = MusicSourceConstant.wy;

  TabController? _tabController;

  ///歌单源 Stream Key
  String _sourceStreamKey = "_sourceStreamKey";

  ///歌单类别 Stream Key
  String _sortStreamKey = "_sortStreamKey";

  ///歌单列表Key
  String _infoStreamKey = "_infoStreamKey";

  ///加载中的Key
  String _loadInfoStreamKey = "_loadInfoStreamKey";

  ///获取所有支持的歌单服务
  final sourceList = squareServiceProviderMange.getSupportSourceList();

  ///歌单服务
  late BaseSongSquareService _service;

  ///当前的类别
  SongSquareSort? _squareSort;

  ///当前的选择Tag
  SongSqurareTagItem? _squareTagItem;

  ///获取的Tags列表对象
  List<SongSqurareTag>? _squrareTags;

  ///分页页码
  int _pageIndex = 1;

  ///分页大小
  int _pageSize = 30;

  @override
  void initState() {
    _source = widget.arauments?.paramsSource ?? MusicSourceConstant.kg;
    _service = squareServiceProviderMange.getSupportProvider(_source).first;

    ///取页面传递来的值进行判断是否进行赋值为初始请求值
    if (widget.arauments?.paramsSort != null) {
      _squareSort = (_service.getSortList() as List<SongSquareSort>)
          .firstWhere((element) => element.id == widget.arauments!.paramsSort);
    } else {
      _squareSort = (_service.getSortList() as List<SongSquareSort>)[0];
    }
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      _createOverlay();
      _loadInfoList();
      _loadTags();
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
    _tabController?.dispose();
    super.dispose();
  }

  ///加载歌单列表
  void _loadInfoList() {
    getLine(_loadInfoStreamKey).setData(true);
    _service
        .getSongSquareInfoList(
            sort: _squareSort,
            tag: _squareTagItem,
            page: _pageIndex,
            size: _pageSize)
        .then((value) {
      getLine(_loadInfoStreamKey).setData(false);
      var siginer = getLine<List<SongSquareInfo>>(_infoStreamKey);
      List<SongSquareInfo> list;
      if (!siginer.hasData()) {
        list = value;
      } else {
        list = siginer.getData()!;
        list.addAll(value);
      }
      siginer.setData(list);
      siginer.forceRefresh();
    }).catchError((e) => ToastUtil.show(msg: e.toString()));
  }

  ///加载标签
  void _loadTags() {
    _service.getTags().then((value) {
      _squrareTags = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return GestureDetector(
      onTap: () {
        if (_overlayEntry.mounted) {
          _overlayEntry.remove();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: AppTheme.reversal(
                AppTheme.getCurrentTheme().scaffoldBackgroundColor),
          ),
          backgroundColor:
              Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
          actions: [
            TextButton(
                key: _globalKey,
                onPressed: () {
                  if (_overlayEntry.mounted) {
                    _overlayEntry.remove();
                  } else {
                    Overlay.of(context)!.insert(_overlayEntry);
                  }
                },
                child: getLine(_sourceStreamKey, initData: _source.desc)
                    .addObserver((context, pack) => Text(
                          pack.data!,
                          style: TextStyle(
                              color: Color(
                                  AppTheme.getCurrentTheme().primaryColor),
                              fontWeight: FontWeight.w500),
                        )))
          ],
          elevation: 0,
          centerTitle: true,
          title: Text(
            "歌单库",
            style: TextStyle(
                color: AppTheme.reversal(
                    AppTheme.getCurrentTheme().scaffoldBackgroundColor)),
          ),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [_toolbar(), Expanded(child: _infoList())],
            ),
          ),
        ),
      ),
    );
  }

  ///列表主页
  Widget _infoList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          getLine<List<SongSquareInfo>>(_infoStreamKey,
                  initData: <SongSquareInfo>[])
              .addObserver((context, pack) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        childAspectRatio: .74),
                    delegate: SliverChildBuilderDelegate((c, i) {
                      if (i >= pack.data!.length - 1) {
                        //加载数据
                        _pageIndex++;
                        _loadInfoList();
                      }
                      var item = pack.data![i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 100,
                            constraints:
                                BoxConstraints(minHeight: 100, maxHeight: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        CachedNetworkImageProvider(item.img))),
                          ),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.reversal(
                                      AppTheme.getCurrentTheme()
                                          .scaffoldBackgroundColor)),
                            ),
                          ))
                        ],
                      );
                    }, childCount: pack.data!.length),
                  )),
          getLine<bool>(_loadInfoStreamKey, initData: true)
              .addObserver((context, pack) => SliverPadding(
                  padding: EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((c, i) {
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  )),
                            )),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                "加载中...",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.reversal(
                                        AppTheme.getCurrentTheme()
                                            .scaffoldBackgroundColor)),
                              ),
                            )
                          ],
                        ),
                      );
                    }, childCount: pack.data! ? 1 : 0),
                  )))
        ],
      ),
    );
  }

  ///标题TabBar选择栏
  Widget _toolbar() {
    List<SongSquareSort> sortList =
        _service.getSortList() as List<SongSquareSort>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
              child: getLine<List<SongSquareSort>>(_sortStreamKey,
                      initData: sortList)
                  .addObserver((context, pack) {
            var index = (_service.getSortList() as List<SongSquareSort>)
                .indexWhere((element) => element == _squareSort);
            _tabController = TabController(
                length: pack.data!.length, vsync: this, initialIndex: index);
            return TabBar(
                onTap: (value) {
                  //同值过滤
                  if (_squareSort == pack.data![value]) return;
                  _squareSort = pack.data![value];
                  _squareTagItem = null;
                  _pageIndex = 1;
                  getLine(_infoStreamKey).setData(<SongSquareInfo>[]);
                  _loadInfoList();
                },
                controller: _tabController,
                physics: BouncingScrollPhysics(),
                indicatorColor: Colors.redAccent.shade100,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                labelColor: Color(AppTheme.getCurrentTheme().primaryColor),
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                unselectedLabelColor:
                    Color(AppTheme.getCurrentTheme().primaryColor)
                        .withOpacity(0.7),
                unselectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                isScrollable: true,
                tabs: pack.data!.map((e) => Text(e.name)).toList());
          })),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: () {
                if (_squrareTags != null) {
                  Application.navigateToIos(context, "/squareTagSelected",
                          params: _squrareTags)
                      .then((value) {
                    if (value != null) {
                      _squareTagItem = value;
                      _pageIndex = 1;
                      getLine(_infoStreamKey).setData(<SongSquareInfo>[]);
                      _loadInfoList();
                    }
                  });
                }
              },
              icon: Icon(Icons.menu_sharp),
            ),
          )
        ],
      ),
    );
  }

  ///初始创建歌单选取下拉框组件OverLay
  void _createOverlay() {
    RenderBox? renderBox =
        _globalKey.currentContext?.findRenderObject() as RenderBox?;
    var size = renderBox?.size;
    var offset = renderBox?.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
              left: offset!.dx - (size!.width / 2),
              top: offset.dy + size.height + 5.0,
              width: size.width + (size.width / 2),
              child: Material(
                elevation: 4.0,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (c, i) => ListTile(
                          onTap: () {
                            _source = sourceList[i]!;
                            _service = squareServiceProviderMange
                                .getSupportProvider(_source)
                                .first;
                            _overlayEntry.remove();
                            var sortList =
                                _service.getSortList() as List<SongSquareSort>;
                            getLine(_sourceStreamKey).setData(_source.desc);
                            getLine(_sortStreamKey).setData(sortList);

                            ///给定初始化的Sort
                            _squareSort = sortList[0];
                            _squareTagItem = null;
                            _pageIndex = 1;
                            getLine(_infoStreamKey).setData(<SongSquareInfo>[]);
                            _loadTags();
                            _loadInfoList();
                          },
                          title: Text(
                            sourceList[i]!.desc,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                    itemCount: sourceList.length),
              ),
            ));
  }
}

///页面传输传递的参数
class SquareListPageArauments {
  String? paramsSort;
  final MusicSourceConstant paramsSource;
  SquareListPageArauments({
    this.paramsSort,
    required this.paramsSource,
  });
}
