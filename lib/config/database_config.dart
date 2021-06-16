import 'dart:convert';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 10:51:33
 * @LastEditTime: 2021-06-16 10:03:57
 */
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:xy_music_mobile/model/base_entity.dart';

class SqlHelper {
  static const _INIT_VERSION = 1;

  static const _NAME = "xy-music.db";

  static int? oldVersion;

  static int? newVersion;

  static Database? _database;

  static init() async {
    var databasesPath = await getDatabasesPath();

    String path = join(databasesPath, _NAME);

    _database = await openDatabase(
      path,
      version: _INIT_VERSION,
      onCreate: (db, version) {},
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        SqlHelper.oldVersion = oldVersion;
        SqlHelper.newVersion = newVersion;
      },
    );
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  ///判断表是否存在
  static Future<bool> isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database!.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res.length > 0;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}

///Sql 提供者父类对象
abstract class SqlBaseProvider<T extends BaseEntity> {
  String getTableName();

  String getTableCreateSql();

  T parse(Map<String, dynamic> map);

  void upgrade(Database db, int oldVersion, int newVersion);

  ///获取数据库对象
  Future<Database> getDataBase() async {
    return await prepare();
  }

  prepare() async {
    var isTableExist = await SqlHelper.isTableExits(getTableName());
    Database database = await SqlHelper.getCurrentDatabase();
    if (!isTableExist) {
      await database.execute(getTableCreateSql());
    }
    //判断是否需要更新
    if (SqlHelper.oldVersion != null && SqlHelper.newVersion != null) {
      if (SqlHelper.oldVersion!.compareTo(SqlHelper.newVersion!) > 0) {
        upgrade(database, SqlHelper.oldVersion!, SqlHelper.newVersion!);
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
      return parse(list[0]);
    }
    return null;
  }

  ///查询数组
  Future<List<T>> list({String? where, List<Object?>? whereArgs}) async {
    Database database = await getDataBase();
    var list = await database.query(getTableName(),
        where: where, whereArgs: whereArgs);
    return list.map((e) => parse(e)).toList();
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
        .map((e) => parse(e))
        .toList();
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

///更新的Sql版本类
class Upgrade {
  final int version;

  final String sql;
  Upgrade({
    required this.version,
    required this.sql,
  });

  Upgrade copyWith({
    int? version,
    String? sql,
  }) {
    return Upgrade(
      version: version ?? this.version,
      sql: sql ?? this.sql,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'sql': sql,
    };
  }

  factory Upgrade.fromMap(Map<String, dynamic> map) {
    return Upgrade(
      version: map['version'],
      sql: map['sql'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Upgrade.fromJson(String source) =>
      Upgrade.fromMap(json.decode(source));

  @override
  String toString() => 'Upgrade(version: $version, sql: $sql)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Upgrade && other.version == version && other.sql == sql;
  }

  @override
  int get hashCode => version.hashCode ^ sql.hashCode;
}
