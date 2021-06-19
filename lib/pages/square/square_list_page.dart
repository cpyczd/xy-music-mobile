import 'package:flutter/material.dart';

import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/service/base_music_service.dart';
import 'package:xy_music_mobile/util/stream_util.dart';

/*
 * @Description: 歌单页
 * @Author: chenzedeng
 * @Date: 2021-06-18 16:12:23
 * @LastEditTime: 2021-06-20 00:33:44
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

  String _infoStreamKey = "_infoStreamKey";

  ///获取所有支持的歌单服务
  final sourceList = squareServiceProviderMange.getSupportSourceList();

  ///歌单服务
  late BaseSongSquareService _service;

  ///当前的类别
  SongSquareSort? _squareSort;

  ///当前的Tag
  SongSqurareTag? _squareTag;

  @override
  void initState() {
    _source = widget.arauments?.paramsSource ?? MusicSourceConstant.wy;
    //默认为酷狗源
    _service = squareServiceProviderMange.getSupportProvider(_source).first;
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      _createOverlay();
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
    return getLine<List<SongSquareInfo>>(_infoStreamKey,
        waitWidget: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              )),
        ))).addObserver((context, pack) => GridView.builder(
        itemCount: pack.data!.length, //预留一个位置给上拉加载的加载框
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 10),
        itemBuilder: (c, i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          );
        }));
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
            var index = 0;
            if (widget.arauments?.paramsSort != null) {
              index = pack.data!.indexWhere(
                  (element) => element.id == widget.arauments?.paramsSort);
              if (index == -1) {
                index = 0;
              }
              widget.arauments?.paramsSort = null;
            }
            _tabController = TabController(
                length: pack.data!.length, vsync: this, initialIndex: index);
            return TabBar(
                onTap: (value) {
                  //类别点击切换类别
                  _squareSort = pack.data![value];
                  //TODO 类别点击后的事件切换
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
              onPressed: () {},
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
                            getLine(_sourceStreamKey).setData(_source.desc);
                            getLine(_sortStreamKey).setData(
                                _service.getSortList() as List<SongSquareSort>);
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
