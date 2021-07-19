import 'dart:convert';

/*
 * @Description:
 * @Author: chenzedeng
 * @Date: 2021-07-17 21:33:06
 * @LastEditTime: 2021-07-19 13:13:19
 */
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:uuid/uuid.dart';
import 'package:xy_music_mobile/util/isolate/thread_pool.dart';

///基于[Isolate]定义线程
///
class Thread {
  final ThreadRunnable runnable;
  FlutterIsolate? _isolate;
  late final ReceivePort _receivePort;
  late final ThreadParams _params;

  String get threadId => _params.threadId;

  Thread({required this.runnable, dynamic params}) {
    _receivePort = ReceivePort();
    _params = ThreadParams(args: params, threadId: Uuid().v1());
    ThreadPool.init();
  }

  Future<void> _run() async {
    _isolate = await FlutterIsolate.spawn(runnable, _params.toJson());
  }

  Future<T> task<T>(String returnMethod) async {
    await _run();
    var event = await onListener(this, returnMethod).first;
    dispose();
    return event.data as T;
  }

  Future<void> run() async {
    await _run();
  }

  dispose() {
    _isolate?.kill();
    IsolateNameServer.removePortNameMapping(threadId);
    _receivePort.close();
  }

  static void send<T>(String threadId, String method, T msg) {
    var sendPort = IsolateNameServer.lookupPortByName(threadId);
    if (sendPort != null) {
      sendPort.send(ThreadEvent(method: method, data: msg, threadId: threadId));
    }
  }

  static Stream<ThreadEvent> onListener(Thread thread, String method) {
    var sendPort = IsolateNameServer.lookupPortByName(thread.threadId);
    if (sendPort == null) {
      IsolateNameServer.registerPortWithName(
          thread._receivePort.sendPort, thread.threadId);
    }
    return thread._receivePort
        .map((event) => event as ThreadEvent)
        .where((event) => event.method == method);
  }

  static void kill(String threadId) {
    var sendPort = IsolateNameServer.lookupPortByName(ThreadPool.ID);
    if (sendPort != null) {
      sendPort.send(ThreadEvent(
          method: ThreadPool.EVENT_CLOSE, data: "Close", threadId: threadId));
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Thread &&
        other.runnable == runnable &&
        other._isolate == _isolate &&
        other._receivePort == _receivePort &&
        other._params == _params;
  }

  @override
  int get hashCode {
    return runnable.hashCode ^
        _isolate.hashCode ^
        _receivePort.hashCode ^
        _params.hashCode;
  }
}

class ThreadParams extends Object {
  Object args;
  final String threadId;
  ThreadParams({
    required this.args,
    required this.threadId,
  });

  ThreadParams copyWith({
    dynamic args,
    String? id,
  }) {
    return ThreadParams(
      args: args ?? this.args,
      threadId: id ?? this.threadId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'args': args,
      'id': threadId,
    };
  }

  factory ThreadParams.fromMap(Map<String, dynamic> map) {
    return ThreadParams(
      args: map['args'],
      threadId: map['id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ThreadParams.fromJson(String source) =>
      ThreadParams.fromMap(json.decode(source));

  @override
  String toString() => 'ThreadParams(args: $args, id: $threadId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThreadParams &&
        other.args == args &&
        other.threadId == threadId;
  }

  @override
  int get hashCode => args.hashCode ^ threadId.hashCode;
}

typedef void ThreadRunnable(String paramsJson);

class ThreadEvent {
  final String method;
  dynamic data;
  final String threadId;
  ThreadEvent({
    required this.method,
    required this.data,
    required this.threadId,
  });
}
