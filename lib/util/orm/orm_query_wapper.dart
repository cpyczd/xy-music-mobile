/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-11 18:34:26
 * @LastEditTime: 2021-07-15 14:37:54
 */
import 'package:xy_music_mobile/util/orm/orm_base_model.dart';

class QueryWapper<T extends OrmBaseModel> {
  late final List<String> _where;

  String? _lastSql;

  String? _orderBy;

  QueryWapper() {
    _where = List.empty(growable: true);
  }

  Object castWhereValue(Object val) {
    if (val.runtimeType == String) {
      return "'$val'";
    }
    return val;
  }

  QueryWapper<T> neq(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum = ${castWhereValue(value)}");
    }
    return this;
  }

  QueryWapper<T> eq(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum != ${castWhereValue(value)}");
    }
    return this;
  }

  QueryWapper<T> orderByDesc(String colum) {
    _orderBy = "ORDER BY $colum DESC";
    return this;
  }

  QueryWapper<T> orderByAsc(String colum) {
    _orderBy = "ORDER BY $colum ASC";
    return this;
  }

  ///大于 >
  QueryWapper<T> gt(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum > ${castWhereValue(value)}");
    }
    return this;
  }

  ///大于等于 >=
  QueryWapper<T> ge(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum >= ${castWhereValue(value)}");
    }
    return this;
  }

  ///小于 <
  QueryWapper<T> lt(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum < ${castWhereValue(value)}");
    }
    return this;
  }

  ///小于等于 <=
  QueryWapper<T> le(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum <= ${castWhereValue(value)}");
    }
    return this;
  }

  ///Like
  QueryWapper<T> like(String colum, Object value, {bool condition = true}) {
    if (condition) {
      _where.add("$colum LIKE '%$value%'");
    }
    return this;
  }

  ///isNull
  QueryWapper<T> eqIn(String colum, List<Object> values) {
    var join = values.join(",");
    _where.add("$colum IN ($join)");
    return this;
  }

  ///isNull
  QueryWapper<T> notIn(String colum, List<Object> values) {
    var join = values.join(",");
    _where.add("$colum NOT IN ($join)");
    return this;
  }

  ///isNull
  QueryWapper<T> isNull(String colum) {
    _where.add("$colum IS NULL");
    return this;
  }

  ///isNotNull
  QueryWapper<T> isNotNull(String colum) {
    _where.add("$colum IS NOT NULL");
    return this;
  }

  ///And()
  QueryWapper<T> and(QueryWapper<T> queryWapper) {
    var where = queryWapper.toWhere(addWherePrefix: false);
    if (where.isNotEmpty) {
      _where.add("AND ( $where )");
    }
    return this;
  }

  ///or()
  QueryWapper<T> or(QueryWapper<T> queryWapper) {
    var where = queryWapper.toWhere(addWherePrefix: false);
    if (where.isNotEmpty) {
      _where.add("OR ( $where )");
    }
    return this;
  }

  ///last()
  QueryWapper<T> last(String sql) {
    if (sql.isNotEmpty) {
      _where.add(sql);
    }
    return this;
  }

  String toWhere({bool addWherePrefix = true}) {
    if (_where.isEmpty) {
      return "";
    }
    StringBuffer sb = StringBuffer();
    if (addWherePrefix) {
      sb.write(" WHERE");
    }
    _where.forEach((element) {
      sb.write(" $element");
      sb.write(" AND");
    });
    var where = sb.toString();
    if (where.endsWith("AND")) {
      where = where.substring(0, where.lastIndexOf("AND"));
    }
    return where;
  }

  String toQuerySql() {
    StringBuffer sb = StringBuffer();
    sb.write(toWhere());
    if (_orderBy != null) {
      sb.write(" $_orderBy");
    }
    if (_lastSql != null) {
      sb.write(" $_lastSql");
    }
    return sb.toString();
  }

  String toDelSql() {
    StringBuffer sb = StringBuffer();
    sb.write(toWhere());
    if (_lastSql != null) {
      sb.write(" $_lastSql");
    }
    return sb.toString();
  }
}
