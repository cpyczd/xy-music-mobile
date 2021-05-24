/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 16:25:35
 * @LastEditTime: 2021-05-24 18:09:31
 */
import 'package:flutter/material.dart';
import 'package:xy_music_mobile/config/logger_config.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _textControl = TextEditingController();

  int pageIndex = 0;

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
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (pageIndex == 1) {
                        //跳转搜索
                        pageIndex = 2;
                      } else {
                        //情况输入
                        _textControl.clear();
                      }
                    },
                    child: Text(
                      pageIndex == 0 ? "搜索" : "取消",
                      style: TextStyle(fontSize: 15, color: Colors.black),
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
                        log.info("点击事件:$index");
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

  ///搜索中显示的提示组件
  Widget showSearchTipWidget() {
    return Container(
      child: Text("提示"),
    );
  }

  ///搜索后的结果
  Widget showSearchResultWidget() {
    return Container(
      child: Text("结果"),
    );
  }
}
