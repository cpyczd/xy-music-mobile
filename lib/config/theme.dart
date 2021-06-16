import 'dart:convert';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-13 22:25:23
 * @LastEditTime: 2021-06-16 20:34:30
 */
import 'package:flutter/material.dart';

class ThemeConfig {
  static final Set<MaterialColor> _themes = {};

  static Set<MaterialColor> get themes => Set.from(_themes);

  ///注册绑定自身
  static void register(MaterialColor color) {
    _themes.add(color);
  }

  static void registers(List<MaterialColor> lists) {
    _themes.addAll(lists);
  }
}

///主题配置实体类
class MaterialColor {
  final String themeName;

  final int primaryColor;

  final int primaryColorLight;

  final int scaffoldBackgroundColor;
  MaterialColor({
    required this.themeName,
    required this.primaryColor,
    required this.primaryColorLight,
    required this.scaffoldBackgroundColor,
  });

  MaterialColor copyWith({
    String? themeName,
    int? primaryColor,
    int? primaryColorLight,
    int? scaffoldBackgroundColor,
  }) {
    return MaterialColor(
      themeName: themeName ?? this.themeName,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryColorLight: primaryColorLight ?? this.primaryColorLight,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeName': themeName,
      'primaryColor': primaryColor,
      'primaryColorLight': primaryColorLight,
      'scaffoldBackgroundColor': scaffoldBackgroundColor,
    };
  }

  factory MaterialColor.fromMap(Map<String, dynamic> map) {
    return MaterialColor(
      themeName: map['themeName'],
      primaryColor: map['primaryColor'],
      primaryColorLight: map['primaryColorLight'],
      scaffoldBackgroundColor: map['scaffoldBackgroundColor'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MaterialColor.fromJson(String source) =>
      MaterialColor.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MaterialColor(themeName: $themeName, primaryColor: $primaryColor, primaryColorLight: $primaryColorLight, scaffoldBackgroundColor: $scaffoldBackgroundColor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaterialColor &&
        other.themeName == themeName &&
        other.primaryColor == primaryColor &&
        other.primaryColorLight == primaryColorLight &&
        other.scaffoldBackgroundColor == scaffoldBackgroundColor;
  }

  @override
  int get hashCode {
    return themeName.hashCode ^
        primaryColor.hashCode ^
        primaryColorLight.hashCode ^
        scaffoldBackgroundColor.hashCode;
  }
}

class AppTheme {
  /// 默认颜色
  static MaterialColor defaultColor = findTheme("default");

  ///返回匹配的第一个元素
  static MaterialColor findTheme(String name) {
    return ThemeConfig._themes
        .firstWhere((element) => element.themeName == name);
  }

  ///获取当前的主题配色配置
  static MaterialColor getCurrentTheme() {
    return defaultColor;
  }

  ///获取主题对象
  static getThemeData({String? theme}) {
    // 获取theme方法： getThemeData();
    MaterialColor materialColor =
        theme == null ? defaultColor : findTheme(theme);

    ThemeData themData = ThemeData(
      scaffoldBackgroundColor:
          Color(materialColor.scaffoldBackgroundColor), // 页面的背景颜色
      primaryColor: Color(materialColor.primaryColor), // 主颜色
      primaryColorLight: Color(materialColor.primaryColorLight),
      // 按钮颜色
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        textTheme: ButtonTextTheme.normal,
        buttonColor: Color(materialColor.primaryColor),
      ),
      // 小部件的前景色（旋钮，文本，过度滚动边缘效果等）。
      accentColor: Color(materialColor.primaryColor),

      // appbar样式
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),

      // 图标样式
      iconTheme: IconThemeData(
        color: Color(materialColor.primaryColor),
      ),

      // 用于自定义对话框形状的主题。
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18.0,
          color: Colors.black87,
        ),
      ),
    );
    return themData;
  }
}
