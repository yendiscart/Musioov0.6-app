// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';



class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  DaoAccess? _daoaccessInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListEntity` (`AudioId` TEXT NOT NULL, `userId` TEXT NOT NULL,`duration` TEXT NOT NULL, `id` TEXT NOT NULL, `name` TEXT NOT NULL, `url` TEXT NOT NULL, `image` TEXT NOT NULL, `artistname` TEXT NOT NULL, PRIMARY KEY (`AudioId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  DaoAccess get daoaccess {
    return _daoaccessInstance ??= _$DaoAccess(database, changeListener);
  }
}

class _$DaoAccess extends DaoAccess {
  _$DaoAccess(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _listEntityInsertionAdapter = InsertionAdapter(
            database,
            'ListEntity',
            (ListEntity item) => <String, Object?>{
                  'AudioId': item.AudioId,
                  'userId': item.userId,
                  'duration': item.duration,
                  'id': item.id,
                  'name': item.name,
                  'url': item.url,
                  'image': item.image,
                  'artistname': item.artistname
                },
            changeListener),   _taskDeletionAdapter = DeletionAdapter(
      database,
      'ListEntity',
      ['AudioId'],
          (ListEntity item) =>
      <String, Object?>{
        'AudioId': item.AudioId,
        'userId': item.userId,
        'duration': item.duration,
        'id': item.id,
        'name': item.name,
        'url': item.url,
        'image': item.image,
        'artistname': item.artistname


      },
      changeListener);



  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListEntity> _listEntityInsertionAdapter;

  final DeletionAdapter<ListEntity> _taskDeletionAdapter;


  @override
  Future<List<ListEntity>> findAllList(String userId) async {
    return _queryAdapter.queryList('SELECT * FROM ListEntity WHERE userId = ?',
        mapper: (Map<String, Object?> row) => ListEntity(
            row['AudioId'] as String,
            row['userId'] as String,
            row['duration'] as String,
            row['id'] as String,
            row['name'] as String,
            row['url'] as String,
            row['image'] as String,
            row['artistname'] as String
        ),
      arguments: [userId],
    );
  }

  @override
  Future<List<ListEntity>> searchAllList(String userId,String search) async {
    return _queryAdapter.queryList('SELECT * FROM ListEntity WHERE userId = ? and name LIKE ?',
      mapper: (Map<String, Object?> row) => ListEntity(
          row['AudioId'] as String,
          row['userId'] as String,
          row['duration'] as String,
          row['id'] as String,
          row['name'] as String,
          row['url'] as String,
          row['image'] as String,
          row['artistname'] as String
      ),
      arguments: [userId,'%$search%'],
    );
  }

  @override
  Stream<ListEntity?> findById(String AudioId,String userId) {
    return _queryAdapter.queryStream('SELECT * FROM ListEntity WHERE AudioId = ? and userId = ?',
        mapper: (Map<String, Object?> row) => ListEntity(
            row['AudioId'] as String,
            row['userId'] as String,
            row['duration'] as String,
            row['id'] as String,
            row['name'] as String,
            row['url'] as String,
            row['image'] as String,
            row['artistname'] as String
        ),
        arguments: [AudioId,userId],
        queryableName: 'ListEntity',
        isView: false);
  }

  @override
  Future<void> insertInList(ListEntity list) async {
    await _listEntityInsertionAdapter.insert(list, OnConflictStrategy.abort);
  }

  @override
  Future<void> delete(ListEntity task) async {
    await _taskDeletionAdapter.delete(task);
  }


}
