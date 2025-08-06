import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class VideoCubit extends Cubit<VideoState> {
  final videos = <DownloadedVideo>[];
  final VideoRepository _repo;

  VideoCubit(this._repo) : super(const VideoState());

  Future<void> getAllVideos({
    required String userId,
    bool refresh = false,
  }) async {
    try {
      if (!refresh && videos.isNotEmpty) return;
      
      videos.addAll(await _repo.getAll({"userId": userId}));
      _emit();
    } catch (e) {
      final err = CustomState(message: e.toString(), title: "Error");
      _emit(error: err);
    }
  }

  void _emit({CustomState? error, CustomState? loading}) {
    emit(VideoState(error: error, loading: loading, videos: videos));
  }
}

@immutable
class VideoState {
  final List<DownloadedVideo> videos;
  final CustomState? loading;
  final CustomState? error;

  const VideoState({this.videos = const [], this.loading, this.error});
}

class CustomState extends BaseCustomState {
  CustomState({required super.message, required super.title});
}
