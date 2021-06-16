/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 16:56:38
 * @LastEditTime: 2021-06-16 23:07:01
 */
import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  final Icon icon;

  final String text;

  final TextStyle? textStyle;

  final double size;

  const TextIconButton(
      {Key? key,
      this.onPressed,
      this.size = 5,
      required this.icon,
      required this.text,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(onPressed: onPressed, icon: icon),
        SizedBox.fromSize(
          size: Size.fromHeight(1),
        ),
        Text(
          text,
          style: textStyle ?? TextStyle(color: Colors.black87, fontSize: 12),
        )
      ],
    );
  }
}
