/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-11 18:32:44
 * @LastEditTime: 2021-07-11 22:25:35
 */

import 'package:sqflite/sqflite.dart';
import 'package:xy_music_mobile/util/orm/orm.dart';
import 'package:xy_music_mobile/util/orm/orm_base_model.dart';
import 'package:xy_music_mobile/util/orm/orm_query_wapper.dart';
import 'package:xy_music_mobile/util/orm/orm_update_wapper.dart';

///ORM-DAO 提供者父类对象
abstract class OrmBaseDao<T extends OrmBaseModel> {
  ///获取表名称
  String getTableName();

  ///创建表的语句
  String getTableCreateSql();

  ///类型转换
  T modelCastFromMap(Map<String, dynamic> map);

  ///数据库版本升级触发
  void upgrade(Database db, int oldVersion, int newVersion);

  ///获取数据库对象
  Future<Database> getDataBase() async {
    return await prepare();
  }

  prepare() async {
    var isTableExist = await OrmHelper.isTableExits(getTableName());
    Database database = await OrmHelper.getCurrentDatabase();
    if (!isTableExist) {
      await database.execute(getTableCreateSql());
    }
    //判断是否需要更新
    if (OrmHelper.oldVersion != null && OrmHelper.newVersion != null) {
      if (OrmHelper.oldVersion!.compareTo(OrmHelper.newVersion!) > 0) {
        upgrade(database, OrmHelper.oldVersion!, OrmHelper.newVersion!);
      }
    }
    return database;
  }

  ///插入数据
  Future<T> insert(T row) async {
    Database database = await getDataBase();
    int id = await database.insert(getTableName(), row.toMap());
    row.id = id;
    return row;
  }

  ///更新数据根据Id
  Future<bool> updateById(T row) async {
    if (row.id == null) {
      return Future.error("Id not null");
    }
    Database database = await getDataBase();
    int count = await database.update(getTableName(), row.toMap(),
        where: "_id = ?", whereArgs: [row.id]);
    return count != 0;
  }

  ///查询一条数据
  Future<T?> getOne(int id) async {
    Database database = await getDataBase();
    var list =
        await database.query(getTableName(), where: "_id = ?", whereArgs: [id]);
    if (list.isNotEmpty) {
      return modelCastFromMap(list[0]);
    }
    return null;
  }

  ///查询数组
  Future<List<T>> list({String? where, List<Object?>? whereArgs}) async {
    Database database = await getDataBase();
    var list = await database.query(getTableName(),
        where: where, whereArgs: whereArgs);
    return list.map((e) => modelCastFromMap(e)).toList();
  }

  ///分页查询 current = 1
  Future<List<T>> page(int current, int size,
      {String? where, List<Object?>? whereArgs}) async {
    if (current <= 0) {
      current = 1;
    }
    Database database = await getDataBase();
    return (await database.query(getTableName(),
            where: where,
            whereArgs: whereArgs,
            limit: size,
            offset: current - 1))
        .map((e) => modelCastFromMap(e))
        .toList();
  }

  ///根据条件构造器查询一个数据
  Future<T?> getOneByQueryWapper(QueryWapper<T> wapper) async {
    var sql = wapper.toQuerySql();
    Database database = await getDataBase();
    var res = await database.rawQuery("SELECT * FROM ${getTableName()} $sql");
    if (res.isEmpty) {
      return null;
    }
    return modelCastFromMap(res[0]);
  }

  ///根据条件构造器查询一组数据
  Future<List<T>> getListByQueryWapper(QueryWapper<T> wapper) async {
    var sql = wapper.toQuerySql();
    Database database = await getDataBase();
    return (await database.rawQuery("SELECT * FROM ${getTableName()} $sql"))
        .map((e) => modelCastFromMap(e))
        .toList();
  }

  ///根据条件构造器删除数据
  Future<int> deleteByQueryWapper(QueryWapper<T> wapper) async {
    var sql = wapper.toDelSql();
    Database database = await getDataBase();
    return database.rawDelete("DELETE FROM ${getTableName()} $sql");
  }

  ///根据条件构造器更新数据
  Future<int> updateByQueryWapper(UpdateWapper<T> wapper) async {
    var sql = wapper.toUpdateSql();
    Database database = await getDataBase();
    return database.rawUpdate("UPDATE ${getTableName()} $sql");
  }

  ///删除
  Future<int> delete({String? where, List<Object?>? whereArgs}) async {
    Database database = await getDataBase();
    return database.delete(getTableName(), where: where, whereArgs: whereArgs);
  }

  ///删除根据Id
  Future<int> deleteById(int id) {
    return delete(where: "_id = ?", whereArgs: [id]);
  }

  ///清空数据库
  Future<int> clear() async {
    Database database = await getDataBase();
    return database.delete(getTableName());
  }
}
