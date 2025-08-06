import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/features/stream/views/widgets/build_title.dart';
import 'package:watchmate_app/features/stream/views/widgets/custom_chip.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/video_preview.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  final _socketService = getIt<SocketNamespaceService>();
  final _controller = TextEditingController();
  final _key = GlobalKey<FormState>();
  final _authBloc = getIt<AuthBloc>();
  bool _isDownloading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startLink() {
    if (_isDownloading || !_key.currentState!.validate()) return;
    setState(() => _isDownloading = true);

    final url = _controller.text.trim();
    _socketService.emit(NamespaceType.stream, SocketEvents.stream.downloadYT, {
      "userId": _authBloc.user?.id,
      "url": url,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const BuildTitle(
                  title: "Start streaming with your link.",
                  c2: "download",
                  s1: "You can",
                  c1: "stream",
                  s3: "with",
                  s2: "&",
                ),
                10.h,
                const CustomChip(icon: Icons.add_link, text: "HTTP link"),
                30.h,
                Form(
                  key: _key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CustomTextField(
                    validator: ValidatorBuilder.chain().required().build(),
                    hint: "Please enter a network URL",
                    prefixIcon: const Icon(Icons.link),
                    controller: _controller,
                  ),
                ),
                30.h,
                if (_isDownloading)
                  const MyText(
                    size: AppConstants.subtitle,
                    text: "Downloading Videos",
                    family: AppFonts.bold,
                  ),
                15.h,
                StreamBuilder(
                  stream: _socketService.onEvent(
                    event: SocketEvents.stream.downloadYT,
                    type: NamespaceType.stream,
                  ),
                  builder: (context, sc) {
                    if (sc.hasError) {
                      return const MyText(
                        size: AppConstants.subtitle,
                        text: "Download failed",
                      );
                    }

                    final w = sc.connectionState == ConnectionState.waiting;
                    if (w || !sc.hasData) return const SizedBox.shrink();

                    final json = sc.data;
                    final code = json['code'];
                    final data = code == 400 || code == 500
                        ? json["error"]
                        : Map<String, dynamic>.from(json['data']);

                    if (code == 201) {
                      final video = DownloadingVideo.fromJson(data);
                      if (_isDownloading && video.percent >= 96) {
                        _isDownloading = false;
                      }

                      return VideoPreview(video: video);
                    } else if (code == 200) {
                      if (_isDownloading) _isDownloading = false;
                      final video = DownloadedVideo.fromJson(data);
                      return VideoPreview(video: video);
                    }

                    return MyText(text: data.toString());
                  },
                ),
              ],
            ),
          ).expanded(),
          CustomButton(
            onPressed: _isDownloading ? null : _startLink,
            text: "Add Link",
          ),
        ],
      ).padAll(AppConstants.padding),
    );
  }
}
