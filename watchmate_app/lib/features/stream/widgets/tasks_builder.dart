import 'package:watchmate_app/features/stream/bloc/link_bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/blocs/transfer_bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/custom_checkbox.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class TasksBuilder extends StatelessWidget {
  const TasksBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const MyText(
          family: AppFonts.semibold,
          size: AppConstants.title,
          text: "Tasks",
        ),
        10.h,
        const _BuildUploadTasks(),
        const _BuildLinkTask(VideoType.youtube),
        const _BuildLinkTask(VideoType.direct),
      ],
    );
  }
}

class _BuildLinkTask extends StatelessWidget {
  const _BuildLinkTask(this.type);
  final VideoType type;

  @override
  Widget build(BuildContext context) {
    final color = context.theme.hintColor;

    return BlocBuilder<LinkBloc, LinkState>(
      buildWhen: (p, c) {
        if (type == VideoType.direct) {
          return p.direct != c.direct;
        } else {
          return p.yt != c.yt;
        }
      },
      builder: (context, state) {
        final isDirect = type == VideoType.direct;
        final process = isDirect ? state.direct : state.yt;
        if (process.isLoading) return const SizedBox.shrink();

        if (process.isError) {
          return CustomLabelWidget(
            icon: Icons.running_with_errors_rounded,
            title: "Server Response Error!",
            text: process.error,
            iconSize: 80,
          ).center().padOnly(t: 40);
        }

        return _LinkTaskSection(
          color: color,
          video: process.isDownloading
              ? process.downloadingVideo
              : process.downloadedVideo,
        );
      },
    );
  }
}

class _LinkTaskSection extends StatelessWidget {
  final BaseVideo? video;
  final Color color;

  const _LinkTaskSection({required this.color, required this.video});

  @override
  Widget build(BuildContext context) {
    if (video == null) return const SizedBox.shrink();
    final isDownloading = video is DownloadingVideo;

    return ListTile(
      horizontalTitleGap: 8,
      subtitle: isDownloading
          ? _ProgressBuilder((video as DownloadingVideo).percent / 100, color)
          : MyText(text: "Completed", color: color, size: 11),
      trailing: const CustomCheckBox(isChecked: true, isCircle: true),
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: SizedBox(
          height: 90,
          width: 100,
          child: CacheImage(url: video!.thumbnailURL),
        ),
      ),
      title: MyText(
        overflow: TextOverflow.ellipsis,
        family: AppFonts.semibold,
        text: video!.title,
        maxLines: 2,
      ),
    );
  }
}

class _BuildUploadTasks extends StatelessWidget {
  const _BuildUploadTasks();

  @override
  Widget build(BuildContext context) {
    final color = context.theme.hintColor;

    return BlocBuilder<TransferBloc, TransferState>(
      builder: (context, state) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            if (state.queue.isNotEmpty) 10.h,
            _TaskSection(
              color: color,
              tasks: state.active,
              trailingBuilder: (task) => IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<TransferBloc>().add(
                  CancelTransfer(taskId: task.id),
                ),
              ),
              subtitleBuilder: (task) {
                return _ProgressBuilder(task.progress, color);
              },
            ),
            _TaskSection(
              color: color,
              tasks: state.queue,
              subtitleBuilder: (task) =>
                  MyText(text: "Waiting", color: color, size: 11),
              trailingBuilder: (task) => IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<TransferBloc>().add(
                  CancelTransfer(taskId: task.id),
                ),
              ),
            ),
            _TaskSection(
              color: color,
              tasks: state.completed,
              subtitleBuilder: (task) =>
                  MyText(text: "Completed", color: color, size: 11),
              trailingBuilder: (_) =>
                  const CustomCheckBox(isChecked: true, isCircle: true),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressBuilder extends StatelessWidget {
  const _ProgressBuilder(this.progress, this.color);
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        LinearProgressIndicator(
          backgroundColor: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          value: progress,
          minHeight: 6,
        ).expanded(),
        8.w,
        MyText(
          text: "${(progress * 100).toStringAsFixed(1).padLeft(5)}%",
          family: AppFonts.medium,
          color: color,
          size: 10,
        ),
      ],
    );
  }
}

class _TaskSection extends StatelessWidget {
  final Widget Function(TransferItem task)? subtitleBuilder;
  final Widget Function(TransferItem task) trailingBuilder;
  final List<TransferItem> tasks;
  final Color color;

  const _TaskSection({
    required this.trailingBuilder,
    this.subtitleBuilder,
    required this.color,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tasks
          .map(
            (task) => ListTile(
              horizontalTitleGap: 8,
              subtitle: subtitleBuilder?.call(task),
              contentPadding: EdgeInsets.zero,
              trailing: trailingBuilder(task),
              leading: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(10),
                child: SizedBox(
                  height: 90,
                  width: 100,
                  child: CacheImage(url: task.video.thumbnailURL),
                ),
              ),
              title: MyText(
                overflow: TextOverflow.ellipsis,
                family: AppFonts.semibold,
                text: task.filename,
                maxLines: 2,
                size: 12,
              ),
            ),
          )
          .toList(),
    );
  }
}
