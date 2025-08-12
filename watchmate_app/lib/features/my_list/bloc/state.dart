part of 'bloc.dart';

@immutable
class ListState {
  final PaginatedVideos pagination;
  final CustomState? error;
  final bool loading;

  const ListState({
    this.pagination = const PaginatedVideos(),
    this.loading = false,
    this.error,
  });

  ListState copyWith({
    required PaginatedVideos pagination,
    required CustomState? error,
    required bool loading,
  }) => ListState(error: error, pagination: pagination, loading: loading);
}

class CustomState extends BaseCustomState {
  CustomState({required super.message, required super.title});
}
