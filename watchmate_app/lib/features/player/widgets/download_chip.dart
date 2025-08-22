import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/common/blocs/transfer_bloc/bloc.dart';
import 'package:watchmate_app/extensions/widget_extensions.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/database/db.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class DownloadChip extends StatefulWidget {
  final DownloadedVideo video;
  const DownloadChip({super.key, required this.video});

  @override
  State<DownloadChip> createState() => _DownloadChipState();
}

class _DownloadChipState extends State<DownloadChip> {
  final _transfer = getIt<TransferBloc>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideosTableData?>(
      stream: _transfer.db.watchById(widget.video.id),
      builder: (context, sc) {
        final waiting = sc.connectionState == ConnectionState.waiting;
        if (waiting) return const SizedBox.shrink();

        final isDownloaded = sc.data != null;
        return BlocBuilder<TransferBloc, TransferState>(
          buildWhen: _buildWhen,
          builder: (_, state) {
            final idx = state.active.indexWhere(_filter);
            final progress = idx == -1 ? 1.0 : state.active[idx].progress;

            return CustomChip(
              leading: !isDownloaded && (idx != -1)
                  ? CircularProgressIndicator(
                      strokeWidth: 3,
                      value: progress,
                    ).padAll(2.4)
                  : null,
              icon: isDownloaded
                  ? Icons.download_done
                  : Icons.download_outlined,
              onPressed: () {
                if (idx != -1 || isDownloaded) return;
                _transfer.add(
                  AddTransfer(
                    uploadUrl: widget.video.videoURL,
                    file: widget.video.videoURL,
                    type: TransferType.download,
                    video: widget.video,
                  ),
                );
              },
              text: isDownloaded ? "Downloaded" : "Download",
            );
          },
        );
      },
    );
  }

  bool _filter(TransferItem task) =>
      task.video.videoURL == widget.video.videoURL;
  bool _buildWhen(TransferState p, TransferState c) {
    return c.active.any(_filter);
  }
}
