/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-11 19:23:22
 * @LastEditTime: 2021-07-11 19:36:42
 */
import 'package:xy_music_mobile/util/orm/orm_base_model.dart';
import 'package:xy_music_mobile/util/orm/orm_query_wapper.dart';

class UpdateWapper<T extends OrmBaseModel> extends QueryWapper<T> {
  late final List<String> _sets;

  UpdateWapper() {
    _sets = List.empty(growable: true);
  }

  UpdateWapper<T> set(String colum, Object newVal, {bool condition = true}) {
    if (condition) {
      _sets.add("$colum = ${castWhereValue(newVal)}");
    }
    return this;
  }

  String toSetSql() {
    if (_sets.isEmpty) {
      return "";
    }
    StringBuffer sb = StringBuffer();
    sb.write(" SET");
    _sets.forEach((element) {
      sb.write(" $element");
      sb.write(" ,");
    });
    var sql = sb.toString();
    if (sql.endsWith(",")) {
      sql = sql.substring(0, sql.lastIndexOf(","));
    }
    return sql;
  }

  String toUpdateSql() {
    return toSetSql() + toWhere();
  }
}
