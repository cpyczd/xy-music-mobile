/*
 * @Author Yuchen
 * @Email yustart@foxmail.com
 * @Create 2021-06-28 10:16 下午
 */

import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';

///扁平卡片Box容器
class FlatBox extends StatefulWidget {
  Widget? left;
  Widget? right;
  Widget content;
  EdgeInsetsGeometry? padding;

  FlatBox(
      {Key? key, this.left, this.right, required this.content, this.padding})
      : super(key: key);

  @override
  _FlatBoxState createState() => _FlatBoxState();
}

class _FlatBoxState extends State<FlatBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black12, width: .5))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [widget.left ?? SizedBox(), widget.right ?? SizedBox()],
            ),
          ),
          Expanded(child: widget.content)
        ],
      ),
    );
  }
}
