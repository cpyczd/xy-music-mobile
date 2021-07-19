import 'dart:convert';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 10:51:33
 * @LastEditTime: 2021-07-11 22:30:01
 */
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OrmHelper {
  static const _INIT_VERSION = 1;

  static const _DEFAULT_NAME = "ORM-DEFAULT.db";

  ///指定数据库名称
  static String? _dbName;

  ///指定的数据库版本
  static int? _dbVersion;

  static int? oldVersion;

  static int? newVersion;

  static Database? _database;

  ///设置自定义的DataBaseName
  static void setDataBaseName(String dataBaseName) => _dbName = dataBaseName;

  ///设置自定义的DataBaseVersion
  static void setDataBaseVersion(int dataBaseVersion) =>
      _dbVersion = dataBaseVersion;

  static init() async {
    var databasesPath = await getDatabasesPath();

    String path = join(databasesPath, _dbName ?? _DEFAULT_NAME);

    _database = await openDatabase(
      path,
      version: _dbVersion ?? _INIT_VERSION,
      onCreate: (db, version) {},
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        OrmHelper.oldVersion = oldVersion;
        OrmHelper.newVersion = newVersion;
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
class OrmUpgrade {
  final int version;

  final String sql;
  OrmUpgrade({
    required this.version,
    required this.sql,
  });

  OrmUpgrade copyWith({
    int? version,
    String? sql,
  }) {
    return OrmUpgrade(
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

  factory OrmUpgrade.fromMap(Map<String, dynamic> map) {
    return OrmUpgrade(
      version: map['version'],
      sql: map['sql'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OrmUpgrade.fromJson(String source) =>
      OrmUpgrade.fromMap(json.decode(source));

  @override
  String toString() => 'Upgrade(version: $version, sql: $sql)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrmUpgrade && other.version == version && other.sql == sql;
  }

  @override
  int get hashCode => version.hashCode ^ sql.hashCode;
}
