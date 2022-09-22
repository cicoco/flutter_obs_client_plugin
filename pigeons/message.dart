// @author: tafiagu
// @email: tafiagu@gmail.com
// @date: 2022-09-13 16:26:10

import 'package:pigeon/pigeon.dart';

class ObsRequest {
  String filePath;
  String accessKey;
  String secretKey;
  String endpoint;
  String bucket;
  String securityToken;
  String? prefix;
  String? fileName;

  ObsRequest(this.filePath, this.accessKey, this.secretKey, this.endpoint, this.bucket, this.securityToken,
      {this.prefix, this.fileName});
}

class ObsResponse {
  String objectUrl;

  ObsResponse(this.objectUrl);
}

/// 从flutter发送到原生的方法
@HostApi()
abstract class ObsClientAPI {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  ObsResponse uploadFile(ObsRequest request);
}
