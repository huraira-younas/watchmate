import 'package:watchmate_app/features/stream/bloc/upload_bloc/bloc.dart';
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MyText(
          family: AppFonts.semibold,
          size: AppConstants.title,
          text: "Tasks",
        ),
        _BuildUploadTasks(),
      ],
    );
  }
}

class _BuildUploadTasks extends StatelessWidget {
  const _BuildUploadTasks();

  @override
  Widget build(BuildContext context) {
    final color = context.theme.hintColor;

    return BlocBuilder<UploaderBloc, UploaderState>(
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
                onPressed: () => context.read<UploaderBloc>().add(
                  CancelUpload(taskId: task.id),
                ),
              ),
              subtitleBuilder: (task) {
                return LinearProgressIndicator(
                  backgroundColor: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  value: task.progress,
                  minHeight: 6,
                );
              },
            ),
            _TaskSection(
              color: color,
              tasks: state.queue,
              subtitleBuilder: (task) =>
                  MyText(text: "Waiting", color: color, size: 11),
              trailingBuilder: (task) => IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<UploaderBloc>().add(
                  CancelUpload(taskId: task.id),
                ),
              ),
            ),
            _TaskSection(
              color: color,
              tasks: state.completed,
              subtitleBuilder: (task) =>
                  MyText(text: "Completed", color: color, size: 11),
              trailingBuilder: (_) =>
                  const Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        );
      },
    );
  }
}

class _TaskSection extends StatelessWidget {
  final Widget Function(UploadItem task)? subtitleBuilder;
  final Widget Function(UploadItem task) trailingBuilder;
  final List<UploadItem> tasks;
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
                text: task.filename,
                maxLines: 2,
              ),
            ),
          )
          .toList(),
    );
  }
}
