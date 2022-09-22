import 'message.dart';

class FlutterObsClientPlugin {
  static late ObsClientAPI _api = ObsClientAPI();

  Future<String?> uploadFile(ObsRequest request) async {
    ObsResponse response = await _api.uploadFile(request);
    return response.objectUrl;
  }
}
