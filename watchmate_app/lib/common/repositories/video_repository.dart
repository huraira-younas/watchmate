import 'package:watchmate_app/common/models/video_model/paginated_videos.dart';
import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/common/services/api_service/dio_client.dart';

class VideoRepository {
  final _api = ApiService();

  Future<PaginatedVideos> getAll(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.video.getAll, data: data);
    if (response.error != null) throw response.error!;

    return PaginatedVideos.fromJson(response.body);
  }
}
