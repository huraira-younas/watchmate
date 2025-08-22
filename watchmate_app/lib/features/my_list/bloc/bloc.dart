import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/common/models/video_model/paginated_videos.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/database/db.dart';

part 'event.dart';
part 'state.dart';

enum ListType { public, private, downloads }

class ListBloc extends Bloc<ListEvent, Map<ListType, ListState>> {
  final VideoRepository _repo;
  final AppDatabase _db;

  ListBloc(this._repo, this._db) : super({}) {
    on<FetchVideos>(_onFetchVideos);
    on<DeleteVideo>(_onDeleteVideo);
  }

  Future<void> _onFetchVideos(
    FetchVideos event,
    Emitter<Map<ListType, ListState>> emit,
  ) async {
    final type = event.type;
    final refresh = event.refresh;
    final pagination = state[type]?.pagination ?? const PaginatedVideos();

    try {
      final hasMore = pagination.hasMore;
      if (!refresh && pagination.videos.isNotEmpty && !hasMore) return;

      _emit(pagination: pagination, loading: true, emit: emit, type: type);
      final cursor = !refresh && hasMore
          ? pagination.videos.last.createdAt
          : null;

      PaginatedVideos newPage;
      if (type == ListType.downloads) {
        final payload = await _db.paginateVideos(cursor: cursor);
        final result = payload['result'] as List<dynamic>;
        
        newPage = PaginatedVideos(
          videos: result.map((e) => DownloadedVideo.fromJson(e)).toList(),
          hasMore: payload['hasMore'] ?? false,
          cursor: payload['cursor'],
        );

      } else {
        newPage = await _repo.getAll({
          "cursor": cursor?.toIso8601String(),
          "visibility": type.name,
          "userId": event.userId,
          "isHome": false,
        });
      }

      final page = refresh ? newPage : pagination.mergeNextPage(newPage);
      _emit(emit: emit, pagination: page, type: type);
    } catch (e) {
      final err = CustomState(message: e.toString(), title: "Error");
      _emit(emit: emit, pagination: pagination, type: type, error: err);
      event.onError?.call(err);
    } finally {
      event.onSuccess?.call();
    }
  }

  Future<void> _onDeleteVideo(
    DeleteVideo event,
    Emitter<Map<ListType, ListState>> emit,
  ) async {
    final type = event.type;
    final pagination = state[type]?.pagination;
    if (pagination == null) return;

    try {
      await _repo.deleteVideo({"userId": event.userId, "id": event.id});
      pagination.videos.removeWhere((v) => v.id == event.id);

      _emit(emit: emit, pagination: pagination, type: type);
    } catch (e) {
      final err = CustomState(message: e.toString(), title: "Error");
      _emit(emit: emit, pagination: pagination, type: type, error: err);
      event.onError?.call(err);
    } finally {
      event.onSuccess?.call();
    }
  }

  void _emit({
    required Emitter<Map<ListType, ListState>> emit,
    required PaginatedVideos pagination,
    required ListType type,
    bool loading = false,
    CustomState? error,
  }) {
    final currentState = state[type] ?? const ListState();
    emit({
      ...state,
      type: currentState.copyWith(
        pagination: pagination,
        loading: loading,
        error: error,
      ),
    });
  }
}
