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
