import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static requestStorage() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> result = await [
        Permission.storage,
      ].request();

      PermissionStatus status = result[Permission.storage]!;

      if (Platform.isAndroid && !status.isGranted) {
        exit(0);
      } else if (Platform.isIOS && status.isDenied) {
        exit(0);
      }
    }
  }
}
