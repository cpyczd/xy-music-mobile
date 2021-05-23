/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-23 15:03:50
 * @LastEditTime: 2021-05-23 15:06:58
 */

import 'dart:convert';

import 'dart:io';

String lrcDecode(String content) {
  var hex16 = [
    0x40,
    0x47,
    0x61,
    0x77,
    0x5e,
    0x32,
    0x74,
    0x47,
    0x51,
    0x36,
    0x31,
    0x2d,
    0xce,
    0xd2,
    0x6e,
    0x69
  ];
  var str_enc = base64Decode(content).sublist(4);

  for (var i = 0, len = str_enc.length; i < len; i++) {
    str_enc[i] = str_enc[i] ^ hex16[i % 16];
  }
  var inflated = zlib.decode(str_enc);
  return utf8.decode(inflated);
}
