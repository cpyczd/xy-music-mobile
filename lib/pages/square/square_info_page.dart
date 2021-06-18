import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/text_icon_button.dart';

/*
 * @Description: 歌单详情歌曲页面
 * @Author: cpyczd
 * @Date: 2021-06-18 4:05 下午
 * @LastEditTime: 2021-06-18 16:31:05
 */
class SquareInfoPage extends StatefulWidget {
  SquareInfoPage({Key? key}) : super(key: key);

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
      appBar: AppBar(
        backgroundColor:
            Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        actions: [TextIconButton(icon: Icon(Icons.more), text: "酷狗库")],
        elevation: 0,
        title: Text("歌单库"),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
