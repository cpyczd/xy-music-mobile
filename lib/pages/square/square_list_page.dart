import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
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
 * @LastEditTime: 2021-06-18 23:31:31
 */
class SquareListPage extends StatefulWidget {
  SquareListPage({Key? key}) : super(key: key);

  @override
  _SquareListPageState createState() => _SquareListPageState();
}

class _SquareListPageState extends State<SquareListPage> with MultDataLine {
  ///源
  MusicSourceConstant _source = MusicSourceConstant.wy;
  String _sourceStreamKey = "_sourceStreamKey";

  ///歌单服务
  late BaseSongSquareService _service;

  late OverlayEntry _overlayEntry;

  late BuildContext _context;

  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
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
                  log.d("移除挂载");
                  _overlayEntry.remove();
                } else {
                  Overlay.of(context)!.insert(_overlayEntry);
                }
              },
              child: getLine(_sourceStreamKey, initData: _source.desc)
                  .addObserver((context, data) => Text(
                        data,
                        style: TextStyle(
                            color:
                                Color(AppTheme.getCurrentTheme().primaryColor),
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
            children: [_toolbar()],
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    List<SongSquareSort> sortList =
        _service.getSortList() as List<SongSquareSort>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [],
      ),
    );
  }

  void _createOverlay() {
    RenderBox? renderBox =
        _globalKey.currentContext?.findRenderObject() as RenderBox?;
    var size = renderBox?.size;
    var offset = renderBox?.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
              left: offset!.dx - 10,
              top: offset.dy + size!.height + 5.0,
              width: size.width,
              child: Material(
                elevation: 4.0,
                // child: ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount),
              ),
            ));
  }
}
