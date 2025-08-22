import 'package:watchmate_app/common/widgets/dialog_boxs.dart'
    show confirmDialogue;
import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/widgets/custom_bottom_sheet.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/blocs/transfer_bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/video_preview.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:watchmate_app/common/cubits/video_cubit.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _transfer = getIt<TransferBloc>();
  final _vidCubit = getIt<VideoCubit>();
  final _authBloc = getIt<AuthBloc>();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await _vidCubit.getAllVideos(
      visibility: VideoVisibility.public.name,
      userId: _authBloc.user!.id,
      refresh: true,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: BlocConsumer<VideoCubit, VideoState>(
        listener: (context, state) {
          final error = state.error;
          if (error != null) showAppSnackBar(error.message);
        },
        builder: (context, state) {
          final loading = state.loading;
          if (loading != null) return const VideoCardSkeleton().fadeIn();

          final pagination = state.pagination;
          if (pagination.videos.isEmpty) {
            return const CustomLabelWidget(
              text:
                  "Looks like there are no videos yet on the platform. Please upload one.",
              icon: Icons.insert_emoticon_sharp,
              title: "Oppss.. No Video Found",
            );
          }

          return ListView.separated(
            itemCount: pagination.videos.length,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.padding - 12,
              vertical: AppConstants.padding - 10,
            ),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final video = pagination.videos[idx];
              return VideoPreview(
                onMenuTap: () => _handleBottomSheet(video),
                video: video,
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
