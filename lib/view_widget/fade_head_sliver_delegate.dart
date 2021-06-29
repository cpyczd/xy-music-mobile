/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-29 23:15:55
 * @LastEditTime: 2021-06-29 23:53:27
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SliverFadeDelegate extends SliverPersistentHeaderDelegate {
  final double barHeight;
  final double contentHeight;
  final double paddingTop;
  final double spacing;
  final Widget content;
  final String title;
  final Color barColor;
  List<Widget>? action;
  List<Widget>? insertTopWidget;

  SliverFadeDelegate(
      {required this.barHeight,
      required this.contentHeight,
      required this.paddingTop,
      required this.content,
      this.barColor = Colors.white,
      this.title = "Title",
      this.spacing = 10,
      List<Widget>? action,
      List<Widget>? insertTopWidget}) {
    if (action == null) {
      this.action = [];
    } else {
      this.action = action;
    }
    if (insertTopWidget == null) {
      this.insertTopWidget = [];
    } else {
      this.insertTopWidget = insertTopWidget;
    }
  }

  double makeStickyHeaderBgColor(shrinkOffset) {
    final double alpha = (1 -
            (shrinkOffset / (this.maxExtent - this.minExtent))
                .clamp(0, 1)
                .toDouble())
        .toDouble();
    return alpha;
  }

  ///构建渲染的内容。
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: this.maxExtent,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: (paddingTop + this.barHeight + spacing - shrinkOffset),
              child: Opacity(
                opacity: makeStickyHeaderBgColor(shrinkOffset),
                child: Container(
                  height: contentHeight,
                  child: content,
                ),
              )),
          Positioned(
            left: 0,
            right: 0,
            top: paddingTop,
            child: Container(
              height: this.barHeight,
              child: Stack(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: barColor,
                        // color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        color: barColor,
                        fontWeight: FontWeight.w400,
                        // color: this.makeStickyHeaderTextColor(shrinkOffset, false),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: action!,
                    ),
                  )
                ],
              ),
            ),
          ),
        ]..insertAll(0, insertTopWidget!),
      ),
    );
  }

  ///展开状态下组件的高度；
  @override
  double get maxExtent => barHeight + contentHeight + paddingTop;

  ///收起状态下组件的高度
  @override
  double get minExtent => barHeight + paddingTop;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  ///返回模糊视图
  static Container vague(String imgUrl) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(imgUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(),
        ));
  }
}
