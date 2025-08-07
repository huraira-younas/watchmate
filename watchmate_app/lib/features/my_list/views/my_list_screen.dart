import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/video_preview.dart';
import 'package:watchmate_app/common/cubits/video_cubit.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen>
    with AutomaticKeepAliveClientMixin {
  final _vidCubit = getIt<VideoCubit>();
  final _authBloc = getIt<AuthBloc>();

  final _key = VideoVisibility.private.name;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await _vidCubit.getAllVideos(
      userId: _authBloc.user!.id,
      visibility: _key,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: BlocBuilder<VideoCubit, Map<String, VideoState>>(
        buildWhen: (p, c) => c[_key] != p[_key],
        builder: (context, state) {
          final st = state[_key];
          if (st == null) return const SizedBox.shrink();

          final loading = st.loading;
          final error = st.error;

          if (error != null) {
            return CustomLabelWidget(
              icon: Icons.streetview_sharp,
              text: error.message,
              title: error.title,
            ).fadeIn();
          }

          if (loading != null) return const VideoCardSkeleton().fadeIn();

          final pagination = st.pagination;
          if (pagination.videos.isEmpty) {
            return const CustomLabelWidget(
              text: "No videos found in your list. Try to add one",
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
              return VideoPreview(video: pagination.videos[idx]);
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
