/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-26 22:55:56
 * @LastEditTime: 2021-05-26 23:05:59
 */
import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  final Widget widget;
  final double elevation;

  const CardView({Key? key, required this.widget, this.elevation = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: widget,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.transparent,
          width: 1,
        ),
      ),
    );
  }
}
