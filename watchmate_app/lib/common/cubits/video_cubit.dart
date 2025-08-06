import 'package:watchmate_app/common/models/video_model/paginated_videos.dart';
import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class VideoCubit extends Cubit<VideoState> {
  final VideoRepository _repo;

  VideoCubit(this._repo) : super(const VideoState());

  Future<void> getAllVideos({
    required String userId,
    bool refresh = false,
    String? visibility,
  }) async {
    try {
      final pagination = state.pagination;
      final hasMore = pagination.hasMore;
      if (!refresh && !hasMore) return;

      _emit(
        loading: CustomState(
          message: "Please wait a sec...",
          title: "Fetching Videos",
        ),
      );

      final payload = await _repo.getAll({
        "cursor": hasMore
            ? pagination.videos.last.createdAt.toIso8601String()
            : null,
        "visibility": visibility ?? VideoVisibility.public.name,
        "userId": userId,
        "limit": 4,
      });

      _emit(pagination: pagination.mergeNextPage(payload));
    } catch (e) {
      final err = CustomState(message: e.toString(), title: "Error");
      _emit(error: err);
    }
  }

  void _emit({
    PaginatedVideos? pagination,
    CustomState? loading,
    CustomState? error,
  }) {
    emit(
      VideoState(
        pagination: pagination ?? state.pagination,
        loading: loading,
        error: error,
      ),
    );
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
