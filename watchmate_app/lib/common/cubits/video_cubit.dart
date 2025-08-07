import 'package:watchmate_app/common/models/video_model/paginated_videos.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class VideoCubit extends Cubit<Map<String, VideoState>> {
  final VideoRepository _repo;

  VideoCubit(this._repo) : super({});

  Future<void> getAllVideos({
    required String visibility,
    required String userId,
    bool refresh = false,
  }) async {
    final type = visibility;
    final pagination = state[type]?.pagination ?? const PaginatedVideos();

    try {
      final hasMore = pagination.hasMore;
      if (!refresh && !hasMore) return;

      _emit(
        type: type,
        pagination: pagination,
        loading: CustomState(
          message: "Please wait a sec...",
          title: "Fetching Videos",
        ),
      );

      final payload = await _repo.getAll({
        "visibility": type,
        "userId": userId,
        "cursor": !refresh && hasMore
            ? pagination.videos.last.createdAt.toIso8601String()
            : null,
      });

      final page = refresh ? payload : pagination.mergeNextPage(payload);
      _emit(pagination: page, type: type);
    } catch (e) {
      final err = CustomState(message: e.toString(), title: "Error");
      _emit(pagination: pagination, type: type, error: err);
    }
  }

  void _emit({
    required PaginatedVideos pagination,
    required String type,
    CustomState? loading,
    CustomState? error,
  }) {
    emit({
      ...state,
      type: VideoState(pagination: pagination, loading: loading, error: error),
    });
  }
}

@immutable
class VideoState {
  final PaginatedVideos pagination;
  final CustomState? loading;
  final CustomState? error;

  const VideoState({
    this.pagination = const PaginatedVideos(),
    this.loading,
    this.error,
  });
}

class CustomState extends BaseCustomState {
  CustomState({required super.message, required super.title});
}
