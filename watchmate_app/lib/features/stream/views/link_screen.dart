import 'package:watchmate_app/features/stream/views/widgets/platform_selection.dart';
import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/features/stream/views/widgets/build_title.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/video_preview.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  final _socketService = getIt<SocketNamespaceService>();
  final _authBloc = getIt<AuthBloc>();

  final _dControllers = List.generate(2, (_) => TextEditingController());
  final _dKeys = List.generate(2, (_) => GlobalKey<FormState>());

  final _controller = TextEditingController();
  final _key = GlobalKey<FormState>();

  bool get _isDirect => _type.name == VideoType.direct.name;
  VideoVisibility _visibility = VideoVisibility.public;
  VideoType _type = VideoType.youtube;

  final _event = <String, String>{
    VideoType.direct.name: SocketEvents.stream.downloadDirect,
    VideoType.youtube.name: SocketEvents.stream.downloadYT,
  };

  final _downloadMap = <String, ValueNotifier>{
    VideoType.youtube.name: ValueNotifier<bool>(false),
    VideoType.direct.name: ValueNotifier<bool>(false),
  };

  bool _isDownloading(String type) => _downloadMap[type]?.value ?? false;

  @override
  void dispose() {
    _dControllers.asMap().forEach((_, v) => v.dispose());
    _controller.dispose();
    super.dispose();
  }

  void _startLink() {
    if (_isDownloading(_type.name) || !_key.currentState!.validate()) return;
    if (_isDirect && (_dKeys.any((e) => !e.currentState!.validate()))) {
      return;
    }

    FocusScope.of(context).unfocus();
    setDownloading(_type.name, true);

    Logger.info(tag: "VISIBILITY", message: _visibility.name);
    final thumbnail = _dControllers[1].text.trim();
    final title = _dControllers[0].text.trim();
    final url = _controller.text.trim();

    _socketService.emit(NamespaceType.stream, _event[_type.name]!, {
      if (_isDirect) "thumbnail": thumbnail,
      "visibility": _visibility.name,
      if (_isDirect) "title": title,
      "userId": _authBloc.user?.id,
      "type": _type.name,
      "url": url,
    });
  }

  void setDownloading(String type, bool val) {
    if (val == _isDownloading(type) || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _downloadMap[type]!.value = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: StreamRoutes.link.name,
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
                BuildTitle(
                  title:
                      "Start uploading with ${_type.name.capitalize} video link.",
                  c2: "download",
                  s1: "You can",
                  c1: "stream",
                  s3: "with",
                  s2: "&",
                ),
                10.h,
                const CustomChip(icon: Icons.add_link, text: "HTTP link"),
                30.h,
                CustomCard(
                  margin: 0,
                  padding: 14,
                  child: PlatformSelection(
                    visibility: _visibility,
                    type: _type,
                    onTypeChange: (type) {
                      if (type == _type) return;
                      setState(() => _type = type);
                    },
                    onVisibilityChange: (visibility) {
                      if (visibility == _visibility) return;
                      setState(() => _visibility = visibility);
                    },
                  ),
                ),
                if (_isDirect) ...[
                  20.h,
                  Form(
                    key: _dKeys[0],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CustomTextField(
                      showTitle: true,
                      label: "Video Title",
                      validator: ValidatorBuilder.chain()
                          .required()
                          .min(6)
                          .build(),
                      hint: "Please enter the title of the video",
                      prefixIcon: const Icon(Icons.title),
                      controller: _dControllers[0],
                    ),
                  ),
                  20.h,
                  Form(
                    key: _dKeys[1],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CustomTextField(
                      validator: ValidatorBuilder.chain().required().build(),
                      hint: "Please enter the url of the thumbnail",
                      prefixIcon: const Icon(Icons.image_outlined),
                      label: "Thumbnail Url",
                      controller: _dControllers[1],
                      showTitle: true,
                    ),
                  ),
                ],
                20.h,
                Form(
                  key: _key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CustomTextField(
                    showTitle: true,
                    label: "Video URL",
                    validator: ValidatorBuilder.chain().required().build(),
                    hint: "Please enter a ${_type.name} video URL",
                    prefixIcon: const Icon(Icons.link),
                    controller: _controller,
                  ),
                ),
                30.h,
                _handleStream(
                  type: VideoType.youtube.name,
                  stream: _socketService.onEvent(
                    event: SocketEvents.stream.downloadYT,
                    type: NamespaceType.stream,
                  ),
                ),
                20.h,
                _handleStream(
                  type: VideoType.direct.name,
                  stream: _socketService.onEvent(
                    event: SocketEvents.stream.downloadDirect,
                    type: NamespaceType.stream,
                  ),
                ),
                50.h,
              ],
            ),
          ).expanded(),
          ValueListenableBuilder(
            valueListenable: _downloadMap[_type.name]!,
            builder: (_, downloading, _) {
              return CustomButton(
                onPressed: downloading ? null : _startLink,
                text: "Add Link",
              );
            },
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

  Column _buildPreview({required String type, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MyText(
          size: AppConstants.subtitle,
          text: type.capitalize,
          family: AppFonts.bold,
        ),
        10.h,
        child,
      ],
    );
  }

  StreamBuilder _handleStream({
    required Stream<dynamic> stream,
    required String type,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, sc) {
        if (sc.hasError) {
          return const CustomLabelWidget(
            icon: Icons.running_with_errors_rounded,
            title: "Server Response Error!",
            text: "Something went wrong",
            iconSize: 80,
          ).center().padOnly(t: 40);
        }

        final w = sc.connectionState == ConnectionState.waiting;
        if (w) return const SizedBox.shrink();

        if (!sc.hasData) {
          return _buildPreview(
            child: const VideoCardSkeleton(count: 1),
            type: type,
          );
        }

        final json = sc.data;
        final code = json['code'];
        final data = code != 200 && code != 201
            ? json["error"] ?? json["message"]
            : Map<String, dynamic>.from(json['data']);

        if (code == 201) {
          final video = DownloadingVideo.fromJson(data);
          if (_isDownloading(type) && video.percent >= 96) {
            setDownloading(type, false);
          }

          return _buildPreview(
            child: VideoPreview(video: video),
            type: type,
          );
        } else if (code == 200) {
          if (_isDownloading(type)) setDownloading(type, false);
          final video = DownloadedVideo.fromJson(data);
          return _buildPreview(
            child: VideoPreview(video: video),
            type: type,
          );
        }

        if (_isDownloading(type)) setDownloading(type, false);
        return CustomLabelWidget(
          icon: Icons.wifi_tethering_error_rounded_outlined,
          title: "Error while downloading!",
          text: data.toString(),
          iconSize: 80,
        ).center().padOnly(t: 40);
      },
    );
  }
}
