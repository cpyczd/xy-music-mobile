class EnumUtil {
  ///枚举类型转string
  static String enumToString(o) => o.toString().split('.').last;

  ///string转枚举类型
  static T enumFromString<T>(List<T> values, String value) {
    return values.firstWhere((type) => type.toString().split('.').last == value,
        orElse: () => null);
  }
}
