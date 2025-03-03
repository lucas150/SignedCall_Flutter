import 'dart:convert';

import 'package:clevertap_signedcall_flutter/models/fcm_processing_mode.dart';
import 'package:clevertap_signedcall_flutter/models/swipe_off_behaviour.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'models/FcmProcessingNotification.dart';

class SharedPreferenceManager {
  static Future<bool> saveLoggedInCuid(String cuid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyLoggedInCuid, cuid);
  }

  static Future<String?> getLoggedInCuid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLoggedInCuid);
  }

  static Future<bool> savePoweredByChecked(bool isChecked) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyIsPoweredByChecked, isChecked);
  }

  static Future<bool> getIsPoweredByChecked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsPoweredByChecked) ?? false;
  }

  static Future<bool> saveNotificationPermissionRequired(bool isRequired) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyNotificationPermissionRequired, isRequired);
  }

  static Future<bool> getNotificationPermissionRequired() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotificationPermissionRequired) ?? true;
  }

  static Future<bool> saveSwipeOffBehaviour(SCSwipeOffBehaviour behaviour) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keySwipeOffBehaviour, behaviour.toValue());
  }

  static Future<SCSwipeOffBehaviour> getSwipeOffBehaviour() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final behaviourString = prefs.getString(keySwipeOffBehaviour) ?? SCSwipeOffBehaviour.endCall.toValue();
    return SCSwipeOffBehaviourExtension.fromValue(behaviourString);
  }

  static Future<bool> saveFCMProcessingMode(FCMProcessingMode fcmProcessingMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyFcmProcessingMode, fcmProcessingMode.toValue());
  }

  static Future<FCMProcessingMode> getFCMProcessingMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final processingModeString = prefs.getString(keyFcmProcessingMode) ?? FCMProcessingMode.background.toValue();
    return FCMPocessingModeExtentsion.fromValue(processingModeString);
  }

  static Future<bool> saveFcmProcessingNotification(FCMProcessingNotification settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(settings.toMap());
    return prefs.setString(keyFcmNotification, jsonString);
  }

  static Future<FCMProcessingNotification?> loadFcmProcessingNotification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(keyFcmNotification);
    if (jsonString == null) return null;

    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return FCMProcessingNotification.fromMap(Map<String, String>.from(jsonMap));
  }

  static Future<bool> saveCallScreenOnSignalling(bool isChecked) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyCallScreenOnSignalling, isChecked);
  }

  static Future<bool> getCallScreenOnSignalling() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyCallScreenOnSignalling) ?? true;
  }


  static clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(keyLoggedInCuid);
  }
}
