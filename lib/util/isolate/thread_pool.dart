/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-19 10:56:15
 * @LastEditTime: 2021-07-19 13:10:42
 */

import 'dart:isolate';
import 'dart:ui';
import 'package:xy_music_mobile/util/isolate/thread.dart';

class ThreadPool {
  static const EVENT_CLOSE = "EVENT_CLOSE";
  static const ID = "EVENT_CLOSE_ID";

  static List<Thread> _THREAD_POOL_LIST = [];

  static final ReceivePort _receivePort = ReceivePort();

  static void init() {
    if (IsolateNameServer.lookupPortByName(ID) == null) {
      IsolateNameServer.registerPortWithName(_receivePort.sendPort, ID);
      _receivePort.listen((message) {
        if (message is ThreadEvent && message.method == EVENT_CLOSE) {
          for (var thread in _THREAD_POOL_LIST) {
            if (thread.threadId == message.threadId) {
              thread.dispose();
              remove(thread);
              break;
            }
          }
        }
      });
    }
  }

  static void createThread(Thread thread) {
    _THREAD_POOL_LIST.add(thread);
  }

  static void remove(Thread thread) {
    _THREAD_POOL_LIST.remove(thread);
  }
}
