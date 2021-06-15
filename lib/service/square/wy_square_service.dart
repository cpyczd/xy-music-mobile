/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-15 20:31:33
 * @LastEditTime: 2021-06-15 23:12:59
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:intl/intl.dart';
import 'package:xy_music_mobile/model/source_constant.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'dart:async';

import 'package:xy_music_mobile/service/music_service.dart';
import 'package:xy_music_mobile/util/index.dart';

///网易云歌单解析器   Todo: 后期接口需要接入缓存存储、优化IO性能开销与内存开销
class WySquareServiceImpl extends SongSquareService {
  ///初始化WebApi工具
  late final _WyWebApi webApi;

  WySquareServiceImpl() {
    webApi = _WyWebApi();
  }

  @override
  Future<List<SongSquareMusic>> getSongMusicList(SongSquareInfo info,
      {int size = 10, int current = 1}) async {
    var data = webApi.linuxapi({
      "method": 'POST',
      "url": 'https://music.163.com/api/v3/playlist/detail',
      "params": {"n": 100000, "s": 8, "id": info.id}
    });
    Map resp = await HttpUtil.post("https://music.163.com/api/linux/forward",
        urlParams: true, data: data);
    if (resp["code"] != 200) {
      return Future.error("获取失败");
    }
    List trackIds = resp["playlist"]["trackIds"];
    var splice = trackIds
        .skip((current - 1) * size)
        .take(size)
        .map((e) => e["id"].toString())
        .toList();
    resp = await HttpUtil.post("https://music.163.com/weapi/v3/song/detail",
        options: Options(headers: {
          "User-Agent":
              "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36",
          "origin": "https://music.163.com"
        }),
        urlParams: true,
        data: webApi.webapi({
          "c": '[' + splice.map((id) => ('{"id":' + id + '}')).join(',') + ']',
          "ids": '[' + splice.join(',') + ']',
        }));
    if (resp["code"] != 200) {
      return Future.error("获取失败");
    }
    return (resp["songs"] as List)
        .map((e) => SongSquareMusic(
            id: e["id"].toString(),
            songName: e["name"],
            singer: (e["ar"] as List).map((e) => e["name"]).join("、"),
            album: e["al"]["name"],
            originalData: e,
            source: MusicSourceConstant.wy))
        .toList();
  }

  @override
  Future<List<SongSquareInfo>> getSongSquareInfoList(
      {SongSquareSort? sort,
      SongSqurareTagItem? tag,
      int page = 1,
      int size = 10}) async {
    var data = webApi.webapi({
      "cat": tag != null ? tag.id : "全部",
      "order": sort?.id,
      "limit": page,
      "offset": size * (page - 1),
      "total": true,
    });
    Map resp = await HttpUtil.post("https://music.163.com/weapi/playlist/list",
        data: data, urlParams: true);
    if (resp["code"] != 200) {
      return Future.error("获取失败");
    }
    List playlists = resp["playlists"];
    return playlists
        .map((e) => SongSquareInfo(
            id: e["id"].toString(),
            playCount: formatPlayCount(e["playCount"]),
            name: e["name"],
            time: DateFormat("y年M月d日")
                .format(DateTime.fromMillisecondsSinceEpoch(e["createTime"])),
            img: e["coverImgUrl"],
            desc: e["description"],
            author: e["creator"]["nickname"]))
        .toList();
  }

  String formatPlayCount(int num) {
    if (num > 100000000) return "${(num / 10000000 / 10)}" '亿';
    if (num > 10000) return '${num / 1000 / 10}' '万';
    return "$num";
  }

  @override
  FutureOr<List<SongSquareSort>> getSortList() {
    return [
      SongSquareSort(id: "hot", name: "最热"),
      SongSquareSort(id: "new", name: "最新")
    ];
  }

  @override
  Future<List<SongSqurareTag>> getTags() async {
    var params = webApi.webapi({});
    Map resp = await HttpUtil.post(
        "https://music.163.com/weapi/playlist/catalogue",
        urlParams: true,
        data: params);
    if (resp["code"] != 200) {
      return Future.error("获取失败");
    }
    List<SongSqurareTag> tags = List.empty(growable: true);
    Map all = resp["all"];
    tags.add(SongSqurareTag(name: "默认", source: MusicSourceConstant.wy, tags: [
      SongSqurareTagItem(
          name: all["name"], parentName: "", id: "", parentId: "")
    ]));

    List sub = resp["sub"];
    Map categories = resp["categories"];
    for (var item in categories.entries) {
      int cid = int.parse(item.key);
      String cname = item.value;
      var tag = SongSqurareTag(name: cname, source: MusicSourceConstant.wy);
      tag.tags = sub
          .where((element) => cid == element["category"])
          .map((e) => SongSqurareTagItem(
              id: e["name"],
              name: e["name"],
              parentId: "$cid",
              parentName: cname))
          .toList();
      tags.add(tag);
    }
    return tags;
  }

  @override
  bool support(MusicSourceConstant type, Object? fliter) {
    return type == MusicSourceConstant.wy;
  }
}

///网易WebAPI 参数加密工具
class _WyWebApi {
  final iv = "0102030405060708";
  final presetKey = "0CoJUm6Qyw8W8jud";
  final linuxapiKey = "rFgB&h#%2?^eDg:Q";
  final base62 =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final publicKey =
      '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';
  final secretKeyStr = "tUspQWjQQD1ngqwC";
  final encSecKey =
      "30b74b0f4bfa8c995cdc60753ff9b4e9543e35a658af4e52167fd038c88c6c3fbbbc64a6577583aef19d4d46bc04651489d0f463288511f166c38eb018bbff0db37c369ca81f26ddc9ab3cdf8d9ee1dbfc6122b21200a3aca675a11c54fefd4461980eadc5bf200e90a1f7c01b561d7ccbe12a6873f714c365cc4dc2abb09cb6";

  ///返回webapi加密的参数
  Map<String, String> webapi(Map<String, dynamic> params) {
    var jsonStr = json.encode(params);
    var secretKey = secretKeyStr.codeUnits;
    var pk = aesEncrypt(
            Encrypted.fromUtf8(
                    aesEncrypt(Encrypted.fromUtf8(jsonStr).bytes, presetKey, iv)
                        .base64)
                .bytes,
            String.fromCharCodes(Uint8List.fromList(secretKey)),
            iv)
        .base64;
    return {"params": pk, "encSecKey": encSecKey};
  }

  ///返回linuxapi加密的参数
  Map<String, String> linuxapi(Map<String, dynamic> params) {
    var jsonStr = json.encode(params);
    var eparams = aesEncrypt(Encrypted.fromUtf8(jsonStr).bytes, linuxapiKey, "",
            mode: AESMode.ecb)
        .base16
        .toUpperCase();
    return {"eparams": eparams};
  }

  ///加密
  Encrypted aesEncrypt(List<int> buffer, String key, String iv,
      {AESMode mode = AESMode.cbc}) {
    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: mode));
    return encrypter.encryptBytes(buffer, iv: IV.fromUtf8(iv));
  }
}
