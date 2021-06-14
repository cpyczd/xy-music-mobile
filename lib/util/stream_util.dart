/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 21:33:42
 * @LastEditTime: 2021-06-01 23:20:29
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef SingleDataObserver<T> = Widget Function(BuildContext context, T data);

class SingleDataLine<T> {
  late final StreamController<T> _stream;

  //拿到当前最新的数据
  T? currentData;

  SingleDataLine({T? initData}) {
    currentData = initData;
    _stream = initData == null
        ? BehaviorSubject<T>()
        : BehaviorSubject<T>.seeded(initData);
  }

  Stream<T> get outer => _stream.stream;

  StreamSink<T> get inner => _stream.sink;

  void setData(T t) {
    //同值过滤
    if (t == currentData) return;
    //防止关闭
    if (_stream.isClosed) return;
    currentData = t;
    inner.add(t);
  }

  Widget addObserver(
    Widget Function(BuildContext context, T data) observer,
  ) {
    return DataObserverWidget<T>(this, observer);
  }

  void dispose() {
    _stream.close();
  }
}

class DataObserverWidget<T> extends StatefulWidget {
  final SingleDataLine dataLine;

  final SingleDataObserver<T> observer;

  DataObserverWidget(this.dataLine, this.observer);

  @override
  _DataObserverWidgetState<T> createState() => _DataObserverWidgetState<T>();
}

class _DataObserverWidgetState<T> extends State<DataObserverWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.dataLine.outer,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot != null && snapshot.data != null) {
          return widget.observer(context, snapshot.data as T);
        } else {
          return Row();
        }
      },
    );
  }

  @override
  void dispose() {
    widget.dataLine._stream.close();
    super.dispose();
  }
}

mixin MultDataLine {
  final Map<String, SingleDataLine> dataBus = Map();

  SingleDataLine<T> getLine<T>(String key, {T? initData}) {
    if (!dataBus.containsKey(key)) {
      SingleDataLine<T> dataLine = new SingleDataLine<T>(initData: initData);
      dataBus[key] = dataLine;
    }
    return dataBus[key] as SingleDataLine<T>;
  }

  void disposeDataLine() {
    dataBus.values.forEach((f) => f.dispose());
    dataBus.clear();
  }
}
