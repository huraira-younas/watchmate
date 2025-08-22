import 'package:path_provider/path_provider.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/drift.dart';
import 'dart:io' show File;

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
  Future<void> upsert(Map<String, dynamic> json) async {
    final entry = VideosTableData.fromJson(json);
    await into(videosTable).insertOnConflictUpdate(entry);
  }

  Future<int> deleteVideo({
    required String localPath,
    required String videoId,
  }) {
    File(localPath).deleteSync();
    return (delete(videosTable)..where((t) => t.id.equals(videoId))).go();
  }

  // ---- Reads ----
  Future<VideosTableData?> getById(String videoId) {
    return (select(
      videosTable,
    )..where((t) => t.id.equals(videoId))).getSingleOrNull();
  }

  Stream<VideosTableData?> watchById(String videoId) {
    return (select(
      videosTable,
    )..where((t) => t.id.equals(videoId))).watchSingleOrNull();
  }

  Future<Map<String, dynamic>> paginateVideos({
    DateTime? cursor,
    int limit = 20,
  }) async {
    final query = select(videosTable);

    if (cursor != null) {
      query.where((t) => t.createdAt.isSmallerThanValue(cursor));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    query.limit(limit + 1);

    final results = await query.get();
    if (results.isEmpty) {
      return {"hasMore": false, "cursor": null, "result": []};
    }

    final hasMore = results.length > limit;
    final trimmed = results.take(limit).toList();

    return {
      "cursor": hasMore ? results[limit].createdAt.toIso8601String() : null,
      "result": trimmed.map((e) => e.toJson()).toList(),
      "hasMore": hasMore,
    };
  }
}
