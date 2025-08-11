import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show File;

class SelectVideo extends StatefulWidget {
  const SelectVideo({required this.onSelect, super.key});
  final Function(DownloadedVideo, String, String) onSelect;

  @override
  State<SelectVideo> createState() => _SelectVideoState();
}

class _SelectVideoState extends State<SelectVideo> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _loading = false;
  String? _thumbnail;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: <String>['mkv', 'mov', 'mp4', 'avi'],
      type: FileType.custom,
      allowMultiple: false,
    );

    final file = result?.files.single.path;
    if (file == null) {
      showAppSnackBar("Please select a video");
      return;
    }

    setState(() => _loading = true);
    final uint8list = await VideoThumbnail.thumbnailData(
      imageFormat: ImageFormat.JPEG,
      maxWidth: 1280,
      video: file,
      quality: 80,
    );

    String? thumbPath;
    if (uint8list != null) {
      final tempDir = await getTemporaryDirectory();
      thumbPath = '${tempDir.path}/thumbnail.jpg';
      File(thumbPath).writeAsBytesSync(uint8list);
      setState(() => _thumbnail = thumbPath);
    }

    _chewieController?.dispose();
    _videoController?.dispose();

    _videoController = VideoPlayerController.file(File(file));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      allowFullScreen: true,
      aspectRatio: 16 / 9,
      showControls: true,
      showOptions: false,
      allowMuting: true,
      autoPlay: false,
      looping: false,
    );

    setState(() => _loading = false);

    if (thumbPath != null && _videoController != null) {
      final fileSize = await File(file).length();
      widget.onSelect(
        DownloadedVideo(
          height: _videoController!.value.size.height,
          duration: _videoController!.value.duration,
          width: _videoController!.value.size.width,
          createdAt: DateTime.now(),
          id: const Uuid().v4(),
          size: fileSize,
          userId: "",
        ),
        thumbPath,
        file,
      );
    } else {
      showAppSnackBar("Failed to generate thumbnail");
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        10.h,
        const MyText(
          size: AppConstants.subtitle,
          family: AppFonts.medium,
          text: "Preview",
        ),
        6.h,
        CustomCard(
          padding: 0,
          margin: 0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildPreview(context),
          ),
        ).onTap(_pickFile),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loading =
        _chewieController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized &&
            _videoController!.value.duration.inMilliseconds > 0;

    if (_chewieController != null && !loading) {
      return ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: Chewie(controller: _chewieController!),
      );
    } else if (_thumbnail != null) {
      return CacheImage(url: _thumbnail!);
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.add, color: Theme.of(context).hintColor),
            6.h,
            MyText(
              color: Theme.of(context).hintColor,
              size: AppConstants.subtitle,
              family: AppFonts.medium,
              text: "Select Video",
            ),
          ],
        ),
      );
    }
  }
}
