/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-07 21:44:31
 * @LastEditTime: 2021-07-07 21:52:48
 */

import 'package:flutter/foundation.dart';

enum StoreSpKey {
  ///This is search keywords store key
  SEARCH_HISTOTY_KEY,
  //This is the configuration Key for resolving the playback address.
  MUSIC_PARSE_ROUTE_KEY
}

extension StoreSpKeyExtension on StoreSpKey {
  String get name => describeEnum(this);
  String get key => this.name + "_KEY${this.index}";
}
