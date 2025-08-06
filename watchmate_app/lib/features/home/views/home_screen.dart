import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/video_preview.dart';
import 'package:watchmate_app/common/cubits/video_cubit.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
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
    _vidCubit.getAllVideos(userId: _authBloc.user!.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    super.build(context);

    return BlocBuilder<VideoCubit, VideoState>(
      builder: (context, state) {
        final loading = state.loading;
        final error = state.error;

        if (error != null) {
          return CustomLabelWidget(
            icon: Icons.streetview_sharp,
            text: error.message,
            title: error.title,
          );
        }

        if (loading != null) {
          return LoadingAnimationWidget.bouncingBall(
            color: theme.primaryColor,
            size: 100,
          ).center();
        }

        final videos = state.videos;
        return ListView.separated(
          itemCount: videos.length,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.padding - 12,
            vertical: AppConstants.padding - 10,
          ),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final video = videos[idx];
            return VideoPreview(video: video);
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
