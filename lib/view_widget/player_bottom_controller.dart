/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-30 21:28:42
 * @LastEditTime: 2021-06-30 23:37:22
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/application.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/view_widget/icon_util.dart';

class PlayerBottomControllre extends StatefulWidget {
  const PlayerBottomControllre({Key? key}) : super(key: key);

  @override
  _PlayerBottomControllreState createState() => _PlayerBottomControllreState();
}

class _PlayerBottomControllreState extends State<PlayerBottomControllre> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Application.router.navigateTo(context, "/player",
                  transition: TransitionType.fadeIn);
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  "https://imgessl.kugou.com/uploadpic/softhead/240/20210602/20210602150924868.jpg"),
              child: CircularProgressIndicator(
                value: 0.3,
                strokeWidth: 2,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(AppTheme.getCurrentTheme().primaryColor)),
              ),
            ),
          ),
          SizedBox.fromSize(
            size: Size.fromWidth(15),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "下辈子不一定还能遇见你 (吉他版)",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  "莫叫姐姐",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                )
              ],
            ),
          ),
          SizedBox.fromSize(size: Size.fromWidth(15)),
          _createIconButton(0xe701),
          SizedBox.fromSize(size: Size.fromWidth(15)),
          _createIconButton(0xe602),
          SizedBox.fromSize(size: Size.fromWidth(15)),
          _createIconButton(0xe6a7),
        ],
      ),
    );
  }

  ///创建按钮
  Widget _createIconButton(int hex16, {VoidCallback? callback}) {
    return IconButton(
      onPressed: callback,
      icon: iconFont(
          hex16: hex16,
          size: 18,
          color: Color(AppTheme.getCurrentTheme().primaryColor)),
      padding: EdgeInsets.all(0),
      // splashColor: Colors.transparent,
      // highlightColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: 18, minHeight: 18),
    );
  }
}
