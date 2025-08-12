import 'package:watchmate_app/common/models/video_model/paginated_videos.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

enum ListType { public, private }

class ListBloc extends Bloc<ListEvent, Map<ListType, ListState>> {
  final VideoRepository _repo;

  ListBloc(this._repo) : super({}) {
    on<FetchVideos>(_onFetchVideos);
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

      final payload = await _repo.getAll({
        "isHome": false,
        "userId": event.userId,
        "visibility": type.name,
        "cursor": !refresh && hasMore
            ? pagination.videos.last.createdAt.toIso8601String()
            : null,
      });

      final page = refresh ? payload : pagination.mergeNextPage(payload);
      _emit(emit: emit, pagination: page, type: type);
    } catch (e) {
      final err = CustomState(message: e.toString(), title: "Error");
      _emit(emit: emit, pagination: pagination, type: type, error: err);
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
