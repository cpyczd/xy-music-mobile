/*
 * @Description:
 * @Author: chenzedeng
 * @Date: 2021-07-17 21:33:06
 * @LastEditTime: 2021-07-18 20:56:52
 */
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:xy_music_plugin_thread/forward_event.dart';
import 'package:xy_music_plugin_thread/xy_music_plugin_thread.dart';

///基于[Isolate]定义线程
///
class Thread {
  final ThreadRunnable runnable;
  FlutterIsolate? _isolate;
  dynamic params;

  Thread({required this.runnable, required this.params}) {
    XyMusicPluginThread.init();
  }

  Future<void> _run() async {
    _isolate = await FlutterIsolate.spawn(runnable, params);
  }

  Future<T> task<T>(String returnMethod) async {
    await _run();
    var event = await onListener(returnMethod).first;
    close();
    return event.args as T;
  }

  Future<void> run() async {
    await _run();
  }

  close() {
    _isolate?.kill();
  }

  static void send<T>(String method, T msg) {
    // XyMusicPluginThread.sendForwardEvent(method, msg);
    IsolateNameServer.removePortNameMapping(method);
  }

  static Stream<ForwardEvent> onListener(String method) {
    return XyMusicPluginThread.listenerForwardEvent(method);
  }
}

class ThreadParams {
  final SendPort port;
  dynamic params;
  ThreadParams({
    required this.port,
    this.params,
  });
}

typedef void ThreadRunnable<T>(T params);
