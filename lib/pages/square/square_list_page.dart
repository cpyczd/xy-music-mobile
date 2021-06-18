import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/service/music_service.dart';
import 'package:xy_music_mobile/service/square/kg_square_service.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/text_icon_button.dart';

/*
 * @Description: 歌单页
 * @Author: chenzedeng
 * @Date: 2021-06-18 16:12:23
 * @LastEditTime: 2021-06-18 18:05:34
 */
class SquareListPage extends StatefulWidget {
  SquareListPage({Key? key}) : super(key: key);

  @override
  _SquareListPageState createState() => _SquareListPageState();
}

class _SquareListPageState extends State<SquareListPage> with MultDataLine {
  late SongSquareService _service;

  @override
  void initState() {
    //默认为酷狗源
    _service =
        SquareServiceProviderMange.getSupportProvider(MusicSourceConstant.kg)
            .first;
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
      appBar: AppBar(
        leading: BackButton(
          color: AppTheme.reversal(
              AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        ),
        backgroundColor:
            Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        actions: [
          TextButton(
              onPressed: () {},
              child: Text(
                "酷狗源",
                style: TextStyle(
                    color: Color(AppTheme.getCurrentTheme().primaryColor),
                    fontWeight: FontWeight.w500),
              ))
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
}
