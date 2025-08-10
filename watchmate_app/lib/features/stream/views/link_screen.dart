import 'package:watchmate_app/features/stream/views/widgets/platform_selection.dart';
import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
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
import 'package:watchmate_app/features/stream/bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  final _linkBloc = getIt<LinkBloc>();

  final _dControllers = List.generate(2, (_) => TextEditingController());
  final _dKeys = List.generate(2, (_) => GlobalKey<FormState>());

  final _controller = TextEditingController();
  final _key = GlobalKey<FormState>();

  bool get _isDirect => _type.name == VideoType.direct.name;
  VideoVisibility _visibility = VideoVisibility.public;
  VideoType _type = VideoType.youtube;

  final _lastUsed = <String, String>{
    VideoType.youtube.name: "",
    VideoType.direct.name: "",
  };

  @override
  void dispose() {
    _dControllers.asMap().forEach((_, v) => v.dispose());
    _controller.dispose();
    super.dispose();
  }

  void _startLink() {
    final process = _type == VideoType.direct
        ? _linkBloc.state.direct
        : _linkBloc.state.yt;

    if (process.isDownloading || !_key.currentState!.validate()) return;
    if (_isDirect && (_dKeys.any((e) => !e.currentState!.validate()))) {
      return;
    }

    FocusScope.of(context).unfocus();

    Logger.info(tag: "VISIBILITY", message: _visibility.name);
    final thumbnail = _dControllers[1].text.trim();
    final title = _dControllers[0].text.trim();
    final url = _controller.text.trim();

    _lastUsed[_visibility.name] = url;
    _linkBloc.add(LinkSubmitted(url: url, title: title, thumbnail: thumbnail));
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
                      _linkBloc.add(LinkTypeChanged(type: type));
                    },
                    onVisibilityChange: (visibility) {
                      if (visibility == _visibility) return;
                      setState(() => _visibility = visibility);
                      _linkBloc.add(
                        LinkVisibilityChanged(visibility: visibility),
                      );
                    },
                  ),
                ),
                if (_isDirect) ...[
                  20.h,
                  Form(
                    key: _dKeys[0],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CustomTextField(
                      hint: "Please enter the title of the video",
                      prefixIcon: const Icon(Icons.title),
                      onChange: (p0) => setState(() {}),
                      controller: _dControllers[0],
                      label: "Video Title",
                      showTitle: true,
                      validator: ValidatorBuilder.chain()
                          .required()
                          .min(6)
                          .build(),
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
                      controller: _dControllers[1],
                      label: "Thumbnail Url",
                      showTitle: true,
                    ),
                  ),
                ],
                20.h,
                Form(
                  key: _key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CustomTextField(
                    validator: ValidatorBuilder.chain().required().build(),
                    hint: "Please enter a ${_type.name} video URL",
                    prefixIcon: const Icon(Icons.link),
                    controller: _controller,
                    label: "Video URL",
                    showTitle: true,
                  ),
                ),
                30.h,
                _handleStream(type: VideoType.youtube.name),
                20.h,
                _handleStream(type: VideoType.direct.name),
                50.h,
              ],
            ),
          ).expanded(),
          BlocBuilder<LinkBloc, LinkState>(
            buildWhen: (p, c) => _buildWhen(p, c, _type.name),
            builder: (context, state) {
              final process = _type == VideoType.direct
                  ? state.direct
                  : state.yt;

              final disabled = process.isDownloading || process.isLoading;
              return CustomButton(
                onPressed: disabled ? null : _startLink,
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

  Widget _handleStream({required String type}) {
    return BlocBuilder<LinkBloc, LinkState>(
      buildWhen: (p, c) => _buildWhen(p, c, type),
      builder: (context, state) {
        final process = type == VideoType.direct.name ? state.direct : state.yt;

        if (process.isLoading) {
          return _buildPreview(
            child: const VideoCardSkeleton(count: 1),
            type: type,
          );
        }

        if (process.isError) {
          return CustomLabelWidget(
            icon: Icons.running_with_errors_rounded,
            title: "Server Response Error!",
            text: process.error,
            iconSize: 80,
          ).center().padOnly(t: 40);
        }

        if (process.isDownloading) {
          return _buildPreview(
            child: VideoPreview(video: process.downloadingVideo!),
            type: type,
          );
        }

        if (process.isSuccess) {
          return _buildPreview(
            child: VideoPreview(video: process.downloadedVideo!),
            type: type,
          );
        }

        return const SizedBox.shrink();
      },
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

  bool _buildWhen(LinkState p, LinkState c, String type) {
    if (type == VideoType.direct.name) {
      return p.direct != c.direct;
    } else {
      return p.yt != c.yt;
    }
  }
}
