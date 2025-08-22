import 'package:path_provider/path_provider.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/drift.dart';

import 'tables/videos.dart';
part 'db.g.dart';

@DriftDatabase(tables: [VideosTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'watchmate_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  // ---- Writes ----
  Future<void> upsert(VideosTableCompanion entry) async {
    await into(videosTable).insertOnConflictUpdate(entry);
  }

  Future<int> deleteById(String videoId) {
    return (delete(videosTable)..where((t) => t.id.equals(videoId))).go();
  }

  // ---- Reads ----
  Future<bool> isDownloaded(String videoId) async {
    final row = await (select(
      videosTable,
    )..where((t) => t.id.equals(videoId))).getSingleOrNull();
    return row != null;
  }

  Future<VideosTableData?> getById(String videoId) {
    return (select(
      videosTable,
    )..where((t) => t.id.equals(videoId))).getSingleOrNull();
  }
}
