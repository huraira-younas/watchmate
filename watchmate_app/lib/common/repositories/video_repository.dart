import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/services/api_service/api_routes.dart';
import 'package:watchmate_app/services/api_service/dio_client.dart';

class VideoRepository {
  final _api = ApiService();

  Future<List<DownloadedVideo>> getAll(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.video.getAll, data: data);
    if (response.error != null) throw response.error!;

    final list = List<dynamic>.from(response.body);
    return list.map((e) => DownloadedVideo.fromJson(e)).toList();
  }
}
