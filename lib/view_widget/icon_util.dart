/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-28 21:41:48
 * @LastEditTime: 2021-07-03 17:08:40
 */
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

///阿里IconFont组件
Icon iconFont({required int hex16, double? size, Color? color}) => Icon(
      IconData(hex16, fontFamily: 'iconfont'),
      color: color,
      size: size,
    );

///Svg组件工具
SvgPicture svg(
        {required String name, Color? color, double? width, double? height}) =>
    SvgPicture.asset(
      "assets/svg/$name.svg",
      color: color,
      width: width,
      height: height,
    );
