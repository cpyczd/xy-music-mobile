/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 17:36:00
 * @LastEditTime: 2021-05-24 21:12:49
 */
import 'dart:convert';
import 'dart:io';

import 'package:xy_music_mobile/util/index.dart';

main() async {
  var str = "RELWORD=还是会想你  林哒浪\r\nSNUM=2403\r\nRNUM=1000\r\nTYPE=0";
  print(str.substring(str.indexOf("=") + 1, str.indexOf("\r")));
}
