import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/video_preview.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _socketService = getIt<SocketNamespaceService>();

  @override
  void initState() {
    super.initState();
    _socketService.emit(NamespaceType.stream, SocketEvents.stream.getAll, null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder(
      stream: _socketService.onEvent(
        event: SocketEvents.stream.getAll,
        type: NamespaceType.stream,
      ),
      builder: (context, sc) {
        if (sc.hasError) {
          return const MyText(
            size: AppConstants.subtitle,
            text: "Get All failed",
          );
        }

        final w = sc.connectionState == ConnectionState.waiting;
        if (w || !sc.hasData) {
          return const CustomLabelWidget(
            text: "Looks like there is no video yet, Try uploading one.",
            title: "Looking for video",
            icon: Icons.browse_gallery,
          );
        }

        final json = sc.data;
        final code = json['code'];
        final data = code == 400 || code == 500
            ? json["error"]
            : List<dynamic>.from(json['data']);

        if (code == 200) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.padding - 12,
              vertical: AppConstants.padding - 10,
            ),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final video = DownloadedVideo.fromJson(data[index]);
              return VideoPreview(video: video);
            },
            itemCount: data.length,
          );
        }

        return MyText(text: data.toString());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
