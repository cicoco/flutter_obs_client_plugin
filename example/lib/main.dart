import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_obs_client_plugin/flutter_obs_client_plugin.dart';
import 'package:flutter_obs_client_plugin/message.dart';
import 'package:flutter_obs_client_plugin_example/permission_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

void main() {
  runApp(MaterialApp(home: RouterTestRoute()));
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  AssetPicker.registerObserve();
}

class RouterTestRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        child: Text('click'),
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return new TestPage();
            }),
          );
          print("路由返回值: " + result);
        },
      ),
    ));
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _platformVersion = 'Unknown';
  final _flutterObsClientPlugin = FlutterObsClientPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await PermissionUtils.requestStorage();

    String platformVersion = "preparing";
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                  onPressed: () {
                    onPressDown();
                  },
                  child: Text('test'))
            ],
          )),
    );
  }

  void onPressDown() async {
    String platformVersion = "get failed";
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(context);
      if (null != result) {
        AssetEntity entity = result[0];
        final File? file = await entity.file;
        final String filePath = file!.path;

        print("filePath:::${filePath}");

        String ak = "DIKB8KUS6BM8LH96GC75";
        String sk = "3aObSfVNRhN2SZG7ZmBSnwD7NyvJnhaR5tfE8rxx";
        String endpoint = "https://obs.cn-north-4.myhuaweicloud.com";
        String token =
            "gQpjbi1ub3J0aC00inBtDENiyBBpLCWnkxv5sUql-B_FDdn-GBzmoOA3cKqIpkTmx8W36Gl2UInPxCn_9H3EtrLOQTfDyiqo3_fTG8iKrCfpjLxDgp3jFk0eqmdStGDwGrji7AxfxovPycXP6DrlIMZ69Ymq9lg6sTOk9Vg20J7pjeb3EYuOnFyfUxhbQFiVR0O9Xe0-occQBL2ND6xEEmKDErYdfkqfNjHgmsnPmqu7f-EQk7Z8mrXOzZC30G-qiDqzzv2VtwnlSxbtGHYoUnaF_P4omRqFVJ4rB0uPTQl7pSSOMmLgtGm9kpIVTtlLCw4-aiOZ6VE-mZfns2Tzvsf9gm_uN6H8T9twUPdp0ivSV66QhKll6_cZk_tGD5cQ5CKHO_XgQXb2KH-D_JIKvHqaGDhyhVWGOIHXBP-aqNnSoAayYQ_F1FcIXkqQzUhBMeR0FVDdJJdALlGhlTcxR2Q8MdCrIhfg8wxT296i6awqs6_wjLPRUG-ZaPdG9kwLCT2HYt9mgDjCDM0kQ2QXZmAOOl3fX7bcOkMSXaihFYZLa46wHHUU2YlxKuupNgpeWWm_AZELWGwMreXjSzfGNcKCs7Q06zpltsgB-38_doDr8EYBCVeXM-VYT2iCvSByK5PlEVx2HH7hugbJQvLk8PChIsIb3uGDbQ9zR1Z4fqXOwPiVfB7BLEQQtkGh0hR9UhJ6vvhwfwQnGpVD4kFI7grMImohgZw5TAF2jlAy4wLhvXD1jNxNx7FzCbgLEyrgSNJdA-3E93b80-WlQDDvzXfpnlTpcO_Co4gJRo0=";
        String bucket = "xxxx";

        ObsRequest request = ObsRequest(
            filePath: filePath, accessKey: ak, secretKey: sk, endpoint: endpoint, bucket: bucket, securityToken: token);
        platformVersion = await _flutterObsClientPlugin.uploadFile(request) ?? 'Unknown platform version';

        print(platformVersion);
      }
    } on PlatformException catch (e) {
      platformVersion = 'Failed to get platform version.';
      print(e);
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }
}
