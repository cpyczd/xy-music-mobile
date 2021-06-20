/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 21:33:42
 * @LastEditTime: 2021-06-20 16:28:18
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef SingleDataObserver<T> = Widget Function(
    BuildContext context, SinglePackageData<T> pack);

class SinglePackageData<T> {
  T? data;
  dynamic params;
  Widget? waitWidget;

  SinglePackageData({
    this.data,
    this.params,
    this.waitWidget,
  });

  @override
  String toString() =>
      'SinglePackageData(data: $data, params: $params, waitWidget: $waitWidget)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SinglePackageData<T> &&
        other.data == data &&
        other.params == params &&
        other.waitWidget == waitWidget;
  }

  @override
  int get hashCode => data.hashCode ^ params.hashCode ^ waitWidget.hashCode;

  SinglePackageData<T> copyWith({
    T? data,
    dynamic params,
    Widget? waitWidget,
  }) {
    return SinglePackageData<T>(
      data: data ?? this.data,
      params: params ?? this.params,
      waitWidget: waitWidget ?? this.waitWidget,
    );
  }
}

class SingleDataLine<T> {
  late final StreamController<SinglePackageData<T>> _stream;

  //拿到当前最新的数据
  SinglePackageData<T>? currentData;

  SingleDataLine({SinglePackageData<T>? initData}) {
    currentData = initData;
    _stream = (initData == null)
        ? BehaviorSubject<SinglePackageData<T>>()
        : BehaviorSubject<SinglePackageData<T>>.seeded(initData);
  }

  Stream<SinglePackageData<T>> get outer => _stream.stream;

  StreamSink<SinglePackageData<T>> get inner => _stream.sink;

  ///设置主数据
  void setData(T? t) {
    //同值过滤
    if (t == currentData) return;
    if (currentData != null && t == currentData!.data) return;
    //防止关闭
    if (_stream.isClosed) return;
    if (currentData == null) {
      currentData = SinglePackageData(data: t);
    } else {
      currentData?.data = t!;
    }
    inner.add(currentData!);
  }

  ///设置其他参数
  void setParams(dynamic params) {
    //同值过滤
    if (params == currentData) return;
    if (currentData != null && params == currentData!.params) return;
    //防止关闭
    if (_stream.isClosed) return;
    if (currentData == null) {
      currentData = SinglePackageData(params: params);
    } else {
      currentData?.data = params;
    }
    inner.add(currentData!);
  }

  ///设置Wiget
  void setWaitWidget(Widget? widget) {
    //同值过滤
    if (currentData != null && widget == currentData!.waitWidget) return;
    //防止关闭
    if (_stream.isClosed) return;
    if (currentData == null) {
      currentData = SinglePackageData(waitWidget: widget);
    } else {
      currentData?.waitWidget = widget;
    }
    inner.add(currentData!);
  }

  ///设置全部数据 根据不为空的进行选择
  void setSignlePackage(SinglePackageData<T> copy) {
    if (currentData == copy) return;
    if (currentData == null) {
      currentData = copy;
    } else {
      currentData = currentData!.copyWith(
          data: copy.data, params: copy.params, waitWidget: copy.waitWidget);
    }
    inner.add(currentData!);
  }

  Widget addObserver(SingleDataObserver<T> observer) {
    return DataObserverWidget<T>(this, observer);
  }

  ///获取Data数据
  T? getData() {
    return currentData?.data;
  }

  ///是否有数据存在
  bool hasData() {
    return currentData != null && currentData!.data != null;
  }

  ///强制刷新
  void forceRefresh() {
    //为空判断
    if (currentData == null) return;
    //防止关闭
    if (_stream.isClosed) return;
    inner.add(currentData!);
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
      initialData: widget.dataLine.currentData,
      stream: widget.dataLine.outer,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data != null &&
            (snapshot.data as SinglePackageData<T>).data != null) {
          return widget.observer(
              context, snapshot.data as SinglePackageData<T>);
        } else {
          if (snapshot.data == null) {
            return Container();
          } else {
            var v = snapshot.data as SinglePackageData<T>;
            return v.waitWidget ?? Container();
          }
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

  SingleDataLine<T> getLine<T>(String key,
      {T? initData, dynamic initpParams, Widget? waitWidget}) {
    if (!dataBus.containsKey(key)) {
      SingleDataLine<T> dataLine = new SingleDataLine<T>(
          initData: SinglePackageData(
              data: initData, params: initpParams, waitWidget: waitWidget));
      dataBus[key] = dataLine;
    }
    return dataBus[key] as SingleDataLine<T>;
  }

  ///使用Futuer初始化数据并返回构建的 observer对象
  FutureBuilder getLineForInitFuture<T>(String key,
      {required Future<T> initData,
      required SingleDataObserver<T> observer,
      dynamic initpParams,
      Widget? waitWidget}) {
    return FutureBuilder(
        future: initData,
        builder: (context, s) {
          if (s.connectionState == ConnectionState.done && s.hasData) {
            if (!dataBus.containsKey(key)) {
              SingleDataLine<T> dataLine = new SingleDataLine<T>(
                  initData: SinglePackageData(
                      data: s.data,
                      params: initpParams,
                      waitWidget: waitWidget));
              dataBus[key] = dataLine;
            }
            var signler = dataBus[key] as SingleDataLine<T>;
            return signler.addObserver(observer);
          }
          return waitWidget ?? Container();
        });
  }

  void disposeDataLine() {
    dataBus.values.forEach((f) => f.dispose());
    dataBus.clear();
  }
}
