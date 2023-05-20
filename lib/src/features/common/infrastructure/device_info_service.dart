import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version_tracker/version_tracker.dart';

const na = 'N/A';

class DeviceInfoService {
  final Map<String, String> _deviceInfo = {};
  late String _appName;
  late String _version;
  late String _versionWithBuildNumber;
  late bool _versionChanged = false;
  late String _packageName;

  Map<String, String> get deviceInfo => _deviceInfo;

  String get appName => _appName;

  String get version => _version;

  String get versionWithBuildNumber => _versionWithBuildNumber;

  bool get versionChanged => _versionChanged;

  Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _packageName = packageInfo.packageName;
      _versionWithBuildNumber = Platform.isWindows ? _version : '$_version+${packageInfo.buildNumber}';

      await _initVersionTracker();

      if (Platform.isAndroid) {
        await _initForAndroid();
      }
    } catch (ex) {
      _version = _versionWithBuildNumber = _appName = _packageName = na;
      _setDefaultDeviceInfoProps(na, na);
    }
  }

  Future<void> _initForAndroid() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    final model = 'Model: ${info.model} --- Device: ${info.device} --- Manufacturer: ${info.manufacturer}';
    _setDefaultDeviceInfoProps(model, '${info.version.sdkInt}');
    _deviceInfo.putIfAbsent('IsPhysicalDevice', () => '${info.isPhysicalDevice}');
  }

  Future<void> _initVersionTracker() async {
    final vt = VersionTracker();
    await vt.track();
    _versionChanged = vt.isFirstLaunchForCurrentBuild ?? vt.isFirstLaunchForCurrentVersion ?? vt.isFirstLaunchEver ?? false;
  }

  void _setDefaultDeviceInfoProps(String model, String osVersion) {
    _deviceInfo..putIfAbsent('Model', () => model)
    ..putIfAbsent('OsVersion', () => osVersion)
    ..putIfAbsent('AppVersion', () => _versionWithBuildNumber)
    ..putIfAbsent('PackageName', () => _packageName);
  }
}
