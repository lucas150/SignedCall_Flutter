import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';

class Utils {
  Utils._();

  static bool didSCAccountCredentialsConfigured() {
    return scAccountId != "YOUR_ACCOUNT_ID" && scApiKey != "YOUR_API_KEY";
  }

  static void showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<bool?> askMicroPhonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      print('Microphone permission granted!');
      return true;
    } else if (status == PermissionStatus.denied) {
      print('Microphone permission denied!');
      askMicroPhonePermission();
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Takes the user to the settings page');
      await openAppSettings();
    }
    return null;
  }

  static Future<bool> isDeviceVersionTargetsBelow(int apiLevel) async {
    String? deviceSdkVersion = await getAndroidDeviceVersion();
    if(deviceSdkVersion != null) {
      return int.parse(deviceSdkVersion) < apiLevel;
    }
    return false;
  }

  static Future<String?> getAndroidDeviceVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    }
    return null;
  }
}
