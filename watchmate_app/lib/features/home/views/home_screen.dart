import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/widgets/custom_bottom_sheet.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
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

  void handleBottomSheet(String videoId) {
    showCustomBottomSheet(
      context: context,
      items: <BottomSheetItem>[
        BottomSheetItem(
          onTap: () => ShareService.shareVideoLink(videoId),
          icon: Icons.share,
          title: "Share",
        ),
        BottomSheetItem(onTap: () {}, icon: Icons.download, title: "Download"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          final loading = state.loading;
          final error = state.error;

          if (error != null) showAppSnackBar(error.message);
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
                onMenuTap: () => handleBottomSheet(video.id),
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
