/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-29 23:15:55
 * @LastEditTime: 2021-06-30 23:05:01
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SliverFadeDelegate extends SliverPersistentHeaderDelegate {
  ///AppBar的高度
  final double barHeight;

  ///内容的高度
  final double contentHeight;

  ///距离顶部的高度 一般设置为状态栏的paddingTop高度
  final double paddingTop;

  ///Appbar和Content的之间间距
  final double spacing;

  ///内容Widget
  final Widget content;

  ///标题
  final String title;

  ///滑动到顶部的时候要切换显示的标题
  String? toTopReplaceTitle;
  final Color barColor;
  List<Widget>? action;

  ///要插入Stack顶部的组件
  List<Widget>? insertTopWidget;

  SliverFadeDelegate(
      {required this.barHeight,
      required this.contentHeight,
      required this.paddingTop,
      required this.content,
      this.barColor = Colors.white,
      this.title = "Title",
      this.spacing = 10,
      this.toTopReplaceTitle,
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
    String titleStr =
        shrinkOffset <= this.maxExtent - this.minExtent - paddingTop
            ? title
            : toTopReplaceTitle ?? title;
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
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: barColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: Text(
                        titleStr,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          color: barColor,
                          fontWeight: FontWeight.w400,
                        ),
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
  static Container vague(String imgUrl,
      {double sigmaX = 30, double sigmaY = 30}) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(imgUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(),
        ));
  }
}
