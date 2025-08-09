import 'package:watchmate_app/features/stream/views/widgets/platform_selection.dart';
import 'package:watchmate_app/features/stream/views/widgets/build_title.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/features/stream/bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _dControllers = List.generate(2, (_) => TextEditingController());
  final _dKeys = List.generate(2, (_) => GlobalKey<FormState>());

  final _controller = TextEditingController();
  final _key = GlobalKey<FormState>();

  VideoVisibility _visibility = VideoVisibility.public;

  @override
  void dispose() {
    _dControllers.asMap().forEach((_, v) => v.dispose());
    _controller.dispose();
    super.dispose();
  }

  void _startLink() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: StreamRoutes.upload.name,
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
                    controller: _dControllers[1],
                    label: "Thumbnail Url",
                    showTitle: true,
                  ),
                ),
                20.h,
                Form(
                  key: _key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CustomTextField(
                    validator: ValidatorBuilder.chain().required().build(),
                    hint: "Please enter a video URL",
                    prefixIcon: const Icon(Icons.link),
                    controller: _controller,
                    label: "Video URL",
                    showTitle: true,
                  ),
                ),
                50.h,
              ],
            ),
          ).expanded(),
          BlocBuilder<LinkBloc, LinkState>(
            builder: (context, state) {
              return CustomButton(onPressed: _startLink, text: "Add Link");
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
}
