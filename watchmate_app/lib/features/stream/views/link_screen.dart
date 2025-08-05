import 'package:watchmate_app/features/stream/views/widgets/build_title.dart';
import 'package:watchmate_app/features/stream/views/widgets/custom_chip.dart';
import 'package:watchmate_app/services/socket_service/socket_events.dart';
import 'package:watchmate_app/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/services/logger.dart';
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

  @override
  void initState() {
    super.initState();
    _socketService.connect(
      query: {"userId": _authBloc.user?.id},
      type: NamespaceType.stream,
    );

    _socketService.onEvent(NamespaceType.stream, SocketEvents.stream.downloadYT).listen((d) {
      Logger.info(tag: SocketEvents.stream.downloadYT, message: d.toString());
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
                const CustomTextField(
                  hint: "Please enter a network URL",
                  prefixIcon: Icon(Icons.link),
                ),
                30.h,
              ],
            ),
          ).expanded(),
          CustomButton(
            text: "Add Link",
            onPressed: () =>
                _socketService.emit(NamespaceType.stream, SocketEvents.stream.downloadYT, {
                  "url": "https://youtu.be/ga1HVaO-n84?si=3MToz4ri6BZ1_HAP",
                  "userId": _authBloc.user?.id,
                }),
          ),
        ],
      ).padAll(AppConstants.padding),
    );
  }
}
