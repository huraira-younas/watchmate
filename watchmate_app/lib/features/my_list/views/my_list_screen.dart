import 'package:watchmate_app/common/widgets/dialog_boxs.dart'
    show confirmDialogue;
import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
import 'package:watchmate_app/features/my_list/widgets/video_card_preview.dart';
import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/features/my_list/widgets/custom_list_tabs.dart';
import 'package:watchmate_app/common/widgets/custom_bottom_sheet.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/blocs/transfer_bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:watchmate_app/features/my_list/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Completer;

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen>
    with AutomaticKeepAliveClientMixin {
  final _uid = getIt<AuthBloc>().user!.id;
  final _transfer = getIt<TransferBloc>();
  final _listBloc = getIt<ListBloc>();

  ListType _key = ListType.public;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList({bool refresh = true}) async {
    final completer = Completer();
    _listBloc.add(
      FetchVideos(
        onSuccess: () => completer.complete(),
        refresh: refresh,
        userId: _uid,
        type: _key,
      ),
    );

    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => showAppSnackBar("Network Request timeout"),
    );
  }

  void changeType(ListType newType) {
    if (newType == _key) return;

    setState(() => _key = newType);
    _fetchList(refresh: false);
  }

  void confirmDelete(String title, String id) async {
    final del = await confirmDialogue(
      message: "Are you sure want to delete '$title'?",
      title: "Delete Video",
      context: context,
    );
    if (!del) return;
    _listBloc.add(
      DeleteVideo(
        onSuccess: () => showAppSnackBar("Video deleted successfully"),
        onError: (e) => showAppSnackBar(e.message),
        userId: _uid,
        type: _key,
        id: id,
      ),
    );
  }

  void _handleBottomSheet(DownloadedVideo video) async {
    final isDownloading = _transfer.state.active.any(
      (e) => e.video.id == video.id,
    );

    final local = (await _transfer.db.getById(video.id));
    final isDownloaded = local != null;
    if (!mounted) return;

    final msg = "Are you sure want to delete ${video.title} from downloads?";
    showCustomBottomSheet(
      context: context,
      items: <BottomSheetItem>[
        BottomSheetItem(
          onTap: () => ShareService.shareVideoLink(video.id),
          icon: Icons.share,
          title: "Share",
        ),
        BottomSheetItem(
          title: isDownloaded
              ? "Remove from downloads"
              : isDownloading
              ? "Downloading..."
              : "Download",
          icon: isDownloaded
              ? Icons.remove_circle_outline
              : isDownloading
              ? Icons.downloading_outlined
              : Icons.download,
          onTap: () async {
            if (isDownloaded) {
              final confirm = await confirmDialogue(
                title: "Delete Download",
                context: context,
                message: msg,
              );
              if (confirm) {
                await _transfer.db.deleteVideo(
                  localPath: local.localPath,
                  videoId: video.id,
                );
              }
              return;
            }

            if (isDownloading) return;
            _transfer.add(
              AddTransfer(
                type: TransferType.download,
                uploadUrl: video.videoURL,
                file: video.videoURL,
                video: video,
              ),
            );
          },
        ),
        if (_key != ListType.downloads)
          BottomSheetItem(
            onTap: () => confirmDelete(video.title, video.id),
            icon: Icons.delete,
            title: "Delete",
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        CustomListTabs(current: _key, onChange: changeType),
        RefreshIndicator(
          onRefresh: _fetchList,
          child: BlocConsumer<ListBloc, Map<ListType, ListState>>(
            listenWhen: (p, c) => c[_key] != p[_key],
            listener: (_, state) {
              final st = state[_key];
              if (st == null) return;

              final error = st.error;
              if (error != null) showAppSnackBar(error.message);
            },
            buildWhen: (p, c) => c[_key] != p[_key],
            builder: (_, state) {
              final st = state[_key];
              if (st == null) return const SizedBox.shrink();

              final loading = st.loading;
              if (loading) return const VideoCardSkeleton().fadeIn();

              final pagination = st.pagination;
              if (pagination.videos.isEmpty) {
                return CustomLabelWidget(
                  text: "No videos found in your ${_key.name}. Try to add one",
                  icon: Icons.insert_emoticon_sharp,
                  title: "Oppss.. No Video Found",
                );
              }

              return ListView.builder(
                itemCount: pagination.videos.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.padding - 12,
                  vertical: AppConstants.padding - 10,
                ),
                itemBuilder: (context, idx) {
                  final video = pagination.videos[idx];
                  return VideoCardPreview(
                    onMenuTap: () => _handleBottomSheet(video),
                    video: video,
                  );
                },
              );
            },
          ),
        ).expanded(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
