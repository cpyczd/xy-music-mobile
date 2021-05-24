/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-21 22:59:39
 * @LastEditTime: 2021-05-21 23:21:12
 */
import 'package:collection/collection.dart';

class EnumUtil {
  ///枚举类型转string
  static String enumToString(o) => o.toString().split('.').last;

  ///string转枚举类型
  static T? enumFromString<T>(List<T> values, String value) {
    return values
        .firstWhereOrNull((type) => type.toString().split('.').last == value);
  }
}

///format number to local number.
///example 10001 -> 1万
///        100 -> 100
///        11000-> 1.1万
String getFormattedNumber(int number) {
  if (number < 10000) {
    return number.toString();
  }
  number = number ~/ 10000;
  return "$number万";
}
