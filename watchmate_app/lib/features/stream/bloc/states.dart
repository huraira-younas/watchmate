part of 'bloc.dart';

enum LinkStatus { initial, loading, downloading, success, error }

class DownloadProcess extends Equatable {
  final DownloadingVideo? downloadingVideo;
  final DownloadedVideo? downloadedVideo;
  final LinkStatus status;
  final String error;

  bool get isDownloading => status == LinkStatus.downloading;
  bool get isLoading => status == LinkStatus.loading;
  bool get isSuccess => status == LinkStatus.success;
  bool get isError => status == LinkStatus.error;

  const DownloadProcess({
    this.status = LinkStatus.initial,
    this.downloadingVideo,
    this.downloadedVideo,
    this.error = '',
  });

  DownloadProcess copyWith({
    DownloadingVideo? downloadingVideo,
    DownloadedVideo? downloadedVideo,
    LinkStatus? status,
    String? error,
  }) {
    return DownloadProcess(
      downloadingVideo: downloadingVideo ?? this.downloadingVideo,
      downloadedVideo: downloadedVideo ?? this.downloadedVideo,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, downloadingVideo, downloadedVideo, error];
}

class LinkState extends Equatable {
  final VideoVisibility visibility;
  final DownloadProcess direct;
  final DownloadProcess yt;
  final VideoType type;

  bool get isPublic => visibility == VideoVisibility.public;
  bool get isDirect => type == VideoType.direct;

  const LinkState({
    this.visibility = VideoVisibility.public,
    this.direct = const DownloadProcess(),
    this.yt = const DownloadProcess(),
    this.type = VideoType.youtube,
  });

  LinkState copyWith({
    VideoVisibility? visibility,
    DownloadProcess? direct,
    DownloadProcess? yt,
    VideoType? type,
  }) {
    return LinkState(
      visibility: visibility ?? this.visibility,
      direct: direct ?? this.direct,
      type: type ?? this.type,
      yt: yt ?? this.yt,
    );
  }

  @override
  List<Object?> get props => [direct, yt, visibility, type];
}
