/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-20 18:03:12
 * @LastEditTime: 2021-06-20 22:47:00
 */
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';

///歌单筛选选择Tag页面
class SquareTagSelectedPage extends StatelessWidget {
  final List<SongSqurareTag> tags;

  const SquareTagSelectedPage({Key? key, required this.tags}) : super(key: key);

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
        elevation: 0,
        centerTitle: true,
        title: Text(
          "歌单筛选",
          style: TextStyle(
              color: AppTheme.reversal(
                  AppTheme.getCurrentTheme().scaffoldBackgroundColor)),
        ),
      ),
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: tags.map((e) => _createTag(context, e)).toList(),
            )),
      ),
    );
  }

  Widget _createTag(BuildContext context, SongSqurareTag tag) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 10),
      sliver: SliverStickyHeader(
        overlapsContent: false,
        header: Container(
          height: 60.0,
          color: Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: Text(
            tag.name,
            style: TextStyle(
                color: AppTheme.reversal(
                    AppTheme.getCurrentTheme().scaffoldBackgroundColor),
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
        ),
        sliver: SliverGrid(
            delegate: SliverChildListDelegate(tag.tags!
                .map((e) => ActionChip(
                      onPressed: () {
                        Application.router.pop(context, e);
                      },
                      label: Text(
                        e.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppTheme.reversal(
                          AppTheme.getCurrentTheme().scaffoldBackgroundColor,
                          opacity: .05),
                    ))
                .toList()),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 3 / 1.5)),
      ),
    );
  }
}
