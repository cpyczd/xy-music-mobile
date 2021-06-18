/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:39:29
 * @LastEditTime: 2021-05-22 16:39:30
 */
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/logger_config.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    log.d("InitState 被调用 =>> SettingPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Setting"),
    );
  }
}
