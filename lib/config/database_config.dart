import 'dart:convert';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 10:51:33
 * @LastEditTime: 2021-06-16 10:03:57
 */
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
