import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_obs_client_plugin/flutter_obs_client_plugin.dart';
import 'package:flutter_obs_client_plugin/flutter_obs_client_plugin_platform_interface.dart';
import 'package:flutter_obs_client_plugin/flutter_obs_client_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterObsClientPluginPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterObsClientPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterObsClientPluginPlatform initialPlatform = FlutterObsClientPluginPlatform.instance;

  test('$MethodChannelFlutterObsClientPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterObsClientPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterObsClientPlugin flutterObsClientPlugin = FlutterObsClientPlugin();
    MockFlutterObsClientPluginPlatform fakePlatform = MockFlutterObsClientPluginPlatform();
    FlutterObsClientPluginPlatform.instance = fakePlatform;
  
    expect(await flutterObsClientPlugin.getPlatformVersion(), '42');
  });
}
