/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:25:35
 * @LastEditTime: 2021-05-24 23:27:14
 */
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/service/kg_music_service.dart';
import 'package:xy_music_mobile/service/music_service.dart';
import 'package:xy_music_mobile/service/tx_music_service.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ///输入框控制器
  TextEditingController _textControl = TextEditingController();

  int pageIndex = 0;

  //搜索建议的Token
  String? _token;

  ///搜索建议列表
  List<String> searchTipData = [];

  ///搜索的关键字
  late String _searchKeyWord;

  ///是否在加载
  bool _isLoading = false;

  ///搜索的结果
  List<MusicEntity> _searchResultList = [];

  ///分页数据
  int _current = 0;
  int _size = 20;

  ///搜索源
  MusicSourceConstant _source = MusicSourceConstant.kg;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _token = await MusicService.getToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            //输入框
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 15, right: 15),
              child: Row(
                children: [
                  Expanded(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 35),
                    child: TextField(
                      controller: _textControl,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      onChanged: (value) {
                        setState(() {
                          value.length == 0 ? pageIndex = 0 : pageIndex = 1;
                          //搜索建议初始化
                          if (value.length != 0) {
                            MusicService.getSearchTip(value, _token)
                                .then((value) {
                              setState(() {
                                searchTipData.clear();
                                if (value.isNotEmpty) {
                                  searchTipData.addAll(value);
                                }
                              });
                            });
                          }
                        });
                      },
                      maxLines: 1,
                      style: TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        fillColor: Color.fromRGBO(235, 238, 245, 1),
                        filled: true,
                        // isCollapsed: true, //重点，相当于高度包裹的意思，必须设置为true，不然有默认奇妙的最小高度
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2), //内容内边距，影响高度
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black38,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(45),
                            gapPadding: 1,
                            borderSide: BorderSide.none),
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (pageIndex != 2) {
                          //跳转搜索
                          _searchKeyWord = _textControl.text;
                          _onSearch();
                        } else {
                          //情况输入
                          _textControl.clear();
                          pageIndex = 0;
                        }
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text(
                      pageIndex != 2 ? "搜索" : "取消",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(15),
              child: (() {
                if (pageIndex == 0) {
                  return showNormalWidget();
                } else if (pageIndex == 1) {
                  return showSearchTipWidget();
                } else {
                  return showSearchResultWidget();
                }
              })(),
            ))
          ],
        ),
      ),
    ));
  }

  ///构建没有搜索的时候页面显示
  Widget showNormalWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "历史",
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: SizedBox(
                      height: 25,
                      width: double.infinity,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        addAutomaticKeepAlives: true,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Text(
                                "世界美好:$index",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            VerticalDivider(
                          width: 16.0,
                          color: Color(0xFFFFFFFF),
                        ),
                      )),
                ),
              )
            ],
          ),
          SizedBox.fromSize(
            size: Size.fromHeight(30),
          ),
          Text("热搜榜",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.redAccent.shade200,
                  fontWeight: FontWeight.w500)),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: 30),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, //横轴三个子widget
                      childAspectRatio: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    var numberColor = Colors.grey;
                    if (index < 3) {
                      numberColor = Colors.red;
                    }
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Row(
                        children: [
                          Text(
                            "${index + 1}.",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: index < 3
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: numberColor),
                          ),
                          SizedBox.fromSize(
                            size: Size.fromWidth(5),
                          ),
                          Text(
                            "假如不再爱你",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: index < 3
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors.black),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  ///搜索中显示的搜索建议
  Widget showSearchTipWidget() {
    return Container(
      child: ListView.builder(
          itemCount: searchTipData.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var key = searchTipData[index].trim();
            return ListTile(
              onTap: () {
                setState(() {
                  _searchKeyWord = key;
                  _textControl.text = key;
                  _resetSearch();
                  _onSearch();
                });
              },
              leading: Icon(Icons.search_sharp),
              title: Align(
                child: Text(key),
                alignment: Alignment.centerLeft,
              ),
              dense: true,
            );
          }),
    );
  }

  ///搜索后的结果
  Widget showSearchResultWidget() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 30,
            child: DefaultTabController(
              length: MusicSourceConstant.values.length - 1,
              child: TabBar(
                onTap: (value) {
                  var replaceSource = MusicSourceConstant.values[value];
                  //如果不是之前的源就重置分页为 0
                  if (replaceSource != _source) {
                    _resetSearch();
                    _source = replaceSource;
                  }
                  _onSearch();
                },
                isScrollable: true,
                tabs: MusicSourceConstant.values
                    .where((element) => element != MusicSourceConstant.none)
                    .map((e) => Text(e.desc))
                    .toList(),
              ),
            ),
          ),
          Expanded(child: (() {
            return _source == MusicSourceConstant.none
                ? Center(child: Text("此源暂不支持"))
                : _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        //分割线构建器
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(height: 0.5, color: Colors.black26);
                        },
                        padding: EdgeInsets.only(top: 20),
                        itemCount: _searchResultList.length,
                        itemBuilder: (context, index) {
                          var subStyle =
                              TextStyle(color: Colors.grey, fontSize: 12);
                          var entity = _searchResultList[index];
                          return ListTile(
                              title: Text(
                                entity.songName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('歌手: ' + (entity.singer ?? "-"),
                                        style: subStyle),
                                    (() {
                                      return entity.songnameOriginal !=
                                              entity.songName
                                          ? Text(
                                              'Cover: ' +
                                                  (entity.songnameOriginal ??
                                                      "-"),
                                              style: subStyle,
                                            )
                                          : SizedBox();
                                    })(),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.more_vert)));
                        });
          })())
        ],
      ),
    );
  }

  void _resetSearch() {
    _current = 0;
    _searchResultList.clear();
  }

  void _onSearch() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_searchKeyWord.isEmpty) {
      return;
    }
    pageIndex = 2;
    //发起搜索
    MusicService? service;
    switch (_source) {
      case MusicSourceConstant.kg:
        service = KGMusicServiceImpl();
        break;
      case MusicSourceConstant.tx:
        service = TxMusicServiceImpl();
        break;
      default:
        //不支持的源
        break;
    }
    if (service == null) {
      setState(() {
        _source = MusicSourceConstant.none;
      });
    } else {
      setState(() {
        _source = _source;
        //开始搜索
        if (_searchResultList.isEmpty) {
          //如果是首次加载显示Loading加载组件
          _isLoading = true;
        }
        service
            ?.searchMusic(_searchKeyWord, size: _size, current: _current)
            .then((value) {
          setState(() {
            if (value.isNotEmpty) {
              _searchResultList.addAll(value);
            }
          });
        }).whenComplete(() => setState(() => _isLoading = false));
      });
    }
  }
}
