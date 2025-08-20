import 'package:watchmate_app/features/stream/widgets/platform_selection.dart';
import 'package:watchmate_app/common/services/api_service/dio_client.dart';
import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/features/stream/bloc/upload_bloc/bloc.dart';
import 'package:watchmate_app/features/stream/widgets/select_video.dart';
import 'package:watchmate_app/features/stream/widgets/build_title.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/utils/network_utils.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _uploader = getIt<UploaderBloc>();
  final _uid = getIt<AuthBloc>().user!.id;
  final _api = ApiService();

  final _controller = TextEditingController();
  final _key = GlobalKey<FormState>();

  VideoVisibility _visibility = VideoVisibility.public;
  String? _pickedFile, _thumbnail;
  DownloadedVideo? _video;
  bool _loading = false;
  final _maxLen = 50;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _uploadThumbnail() async {
    if (_video == null || _thumbnail == null) return "";

    final res = await _api.upload(
      folder: "videos/${_video!.id}",
      url: ApiRoutes.file.upload,
      filePath: _thumbnail!,
      userId: _uid,
    );

    return res.body;
  }

  void _startUpload() async {
    FocusScope.of(context).unfocus();
    if (!(_key.currentState?.validate() ?? false)) return;

    if (_pickedFile == null || _thumbnail == null) {
      showAppSnackBar("Please select a video");
      return;
    }

    setState(() => _loading = true);
    try {
      final thumbnail = await _uploadThumbnail();
      _uploader.add(
        AddUpload(
          uploadUrl: NetworkUtils.baseUrl + ApiRoutes.file.upload,
          file: _pickedFile!,
          video: _video!.copyWith(
            thumbnailURL: thumbnail,
            visibility: _visibility,
          ),
        ),
      );

      if (!mounted) return;
      showAppSnackBar("Task added");
      context.pop();
    } catch (err) {
      setState(() => _loading = false);
      showAppSnackBar("Failed: $err");
    }
  }

  Future<void> _onSelect(
    DownloadedVideo video,
    String thumbnail,
    String file,
  ) async {
    setState(() {
      _thumbnail = thumbnail;
      _pickedFile = file;
    });

    final title = path.basename(file);
    final trimmed = title.length > _maxLen
        ? title.substring(0, _maxLen)
        : title;
        
    _controller.text = trimmed;
    _video = video.copyWith(userId: _uid, title: trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Upload File",
        centerTitle: false,
        context: context,
      ),
      body: Column(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.padding - 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const BuildTitle(
                  title: "Start uploading with local files to server.",
                  c2: "local files",
                  s2: "and serve",
                  s1: "You can",
                  c1: "upload",
                  s3: "with",
                ),
                10.h,
                Row(
                  children: <Widget>[
                    const CustomChip(icon: Icons.video_file, text: ".mp4"),
                    10.w,
                    const CustomChip(icon: Icons.video_file, text: ".avi"),
                    10.w,
                    const CustomChip(icon: Icons.video_file, text: ".mkv"),
                  ],
                ),
                30.h,
                CustomCard(
                  margin: 0,
                  padding: 14,
                  child: PlatformSelection(
                    visibility: _visibility,
                    onVisibilityChange: (visibility) {
                      if (visibility == _visibility) return;
                      setState(() => _visibility = visibility);
                    },
                  ),
                ),
                20.h,
                if (_thumbnail != null)
                  Form(
                    key: _key,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CustomTextField(
                      hint: "Please enter the title of the video",
                      prefixIcon: const Icon(Icons.title),
                      controller: _controller,
                      minLines: 1,
                      maxLines: 2,
                      onChange: (title) {
                        _video = _video?.copyWith(title: title);
                      },
                      label: "Video Title",
                      showTitle: true,
                      validator: ValidatorBuilder.chain()
                          .max(_maxLen)
                          .required()
                          .min(6)
                          .build(),
                    ),
                  ),
                SelectVideo(onSelect: _onSelect),
                50.h,
              ],
            ),
          ).expanded(),
          CustomButton(
            onPressed: _pickedFile == null ? null : _startUpload,
            isLoading: _loading,
            text: "Upload File",
          ).padOnly(
            l: AppConstants.padding - 10,
            r: AppConstants.padding - 10,
            t: AppConstants.padding - 10,
            b: AppConstants.padding,
          ),
        ],
      ),
    );
  }
}
