import 'package:drift/drift.dart';

@TableIndex(name: 'userId_createdAt', columns: {#userId, #createdAt})
class VideosTable extends Table {
  TextColumn get localPath => text()();
  TextColumn get userId => text()();
  TextColumn get id => text()();

  // Metadata
  IntColumn get duration => integer().withDefault(const Constant(0))();
  IntColumn get size => integer()();
  RealColumn get height => real()();
  RealColumn get width => real()();

  // Optional fields
  TextColumn get visibility => text().withDefault(const Constant("public"))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant("direct"))();
  TextColumn get title => text().withDefault(const Constant(""))();
  TextColumn get thumbnailURL => text().nullable()();
  TextColumn get videoURL => text().nullable()();

  // When it was saved locally
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'videos_table';
}
