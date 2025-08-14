import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/common/services/api_service/dio_client.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:watchmate_app/utils/shared_prefs.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'dart:async' show StreamSubscription;
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  final _sp = SharedPrefs.instance;
  StreamSubscription? _linkSub;
  final _api = ApiService();
  final GoRouter _router;

  DeepLinkHandler(this._router);

  void init() {
    dispose();

    try {
      final appLinks = AppLinks();
      _linkSub = appLinks.uriLinkStream.listen(
        handleLink,
        onError: (err) {
          Logger.error(
            message: "DeepLink stream error: $err",
            tag: "App_Links",
          );
        },
      );
    } on PlatformException catch (e) {
      Logger.error(message: "PlatformException: $e", tag: "App_Links");
    } catch (e) {
      Logger.error(message: "DeepLink init failed: $e", tag: "App_Links");
    }
  }

  Future<void> handleLink(Uri uri) async {
    Logger.info(message: "Incoming Link: $uri", tag: "App_Links");

    final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    Logger.info(message: "Incoming Path: $path", tag: "App_Links");

    if ("/$path" != StreamRoutes.player.path) return;

    final id = uri.queryParameters['id']?.trim();
    final partyId = uri.queryParameters['partyId']?.trim();
    
    Logger.info(message: "Incoming partyId: $partyId", tag: "App_Links");
    Logger.info(message: "Incoming Id: $id", tag: "App_Links");

    if (id == null || id.isEmpty) {
      showAppSnackBar("Invalid link: missing video ID");
      return;
    }

    try {
      final uid = _sp.getLoggedUser();
      if (uid == null) {
        return _router.go(AuthRoutes.login.path);
      }

      final res = await _api.post(
        ApiRoutes.video.getVideo,
        data: {"userId": uid, "id": id},
      );

      Logger.info(message: "Incoming Res: $res", tag: "App_Links");

      if (res.statusCode != 200 || res.body == null) {
        showAppSnackBar(res.error ?? "Failed to get video $id");
        return;
      }

      _router.push(
        StreamRoutes.player.path,
        extra: {
          'video': DownloadedVideo.fromJson(res.body),
          'tabPrefix': "home",
          'partyId': partyId,
        },
      );
    } catch (e) {
      showAppSnackBar("Failed: $e");
      Logger.error(message: "DeepLink handleLink failed: $e", tag: "App_Links");
    }
  }

  void dispose() {
    _linkSub?.cancel();
    _linkSub = null;
  }
}
