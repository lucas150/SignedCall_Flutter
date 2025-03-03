import 'dart:io';
import 'dart:math';

import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:clevertap_signedcall_flutter/models/signed_call_error.dart';
import 'package:clevertap_signedcall_flutter/models/swipe_off_behaviour.dart';
import 'package:clevertap_signedcall_flutter/models/fcm_processing_mode.dart';
import 'package:clevertap_signedcall_flutter/plugin/clevertap_signedcall_flutter.dart';
import 'package:clevertap_signedcall_flutter_example/Utils.dart';
import 'package:clevertap_signedcall_flutter_example/constants.dart';
import 'package:clevertap_signedcall_flutter_example/pages/dialler_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/FcmProcessingNotification.dart';
import '../shared_preference_manager.dart';

class RegistrationPage extends StatefulWidget {
  static const routeName = '/registration';
  final String title;

  const RegistrationPage({Key? key, required this.title}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late CleverTapPlugin _clevertapPlugin;
  String _userCuid = '';
  final cuidController = TextEditingController();
  bool isLoadingVisible = false;
  bool isPoweredByChecked = false, notificationPermissionRequired = true, callScreenOnSignalling = false;
  SCSwipeOffBehaviour swipeOffBehaviour = SCSwipeOffBehaviour.endCall;
  FCMProcessingMode fcmProcessingMode = FCMProcessingMode.background;
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final cancelCTALabelController = TextEditingController();
  String cancelCountdownColor = '#F5FA55';

  @override
  void initState() {
    super.initState();
    activateHandlers();
    initSCSDKIfCuIDSignedIn();
  }

  void pushPermissionResponseReceived(bool accepted) {
    debugPrint(
        "Push Permission response called ---> accepted = ${accepted ? "true" : "false"}");
    if (accepted) {
      showLoading();
    } else {
      CleverTapPlugin.promptPushPrimer(getPushPrimerJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Signed Call'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 2),
            const Text(
              'USER-REGISTRATION',
              // textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Image.asset(
              'assets/clevertap-logo.png',
              height: 50,
              width: 100,
            ),
            const SizedBox(height: 2),
            TextField(
              controller: cuidController,
              decoration: const InputDecoration(
                hintText: 'Enter CUID',
              ),
            ),
            CheckboxListTile(
              title: const Text(
                  "Hide Powered by SignedCall",
                  style: TextStyle(fontSize: 12)
              ),
              value: isPoweredByChecked,
              onChanged: (newValue) {
                setState(() {
                  isPoweredByChecked = newValue ?? false;
                });
              },
              controlAffinity:
                  ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text(
                  "Required Notification Permission",
                  style: TextStyle(fontSize: 12)
              ),
              value: notificationPermissionRequired,
              onChanged: (newValue) {
                setState(() {
                  notificationPermissionRequired = newValue ?? false;
                });
              },
              controlAffinity:
              ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text(
                  "Show Call Screen on Signalling",
                  style: TextStyle(fontSize: 12)
              ),
              value: callScreenOnSignalling,
              onChanged: (newValue) {
                setState(() {
                  callScreenOnSignalling = newValue ?? false;
                });
              },
              controlAffinity:
              ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text(
                  "Persist Call on Swipe Off in self-managed FG Service?",
                  style: TextStyle(fontSize: 12)
              ),
              value: swipeOffBehaviour == SCSwipeOffBehaviour.persistCall ? true : false,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    swipeOffBehaviour = newValue
                        ? SCSwipeOffBehaviour.persistCall
                        : SCSwipeOffBehaviour.endCall;
                  });
                }
              },
              controlAffinity:
              ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text(
                  "Use Foreground Service for processing FCM?",
                  style: TextStyle(fontSize: 12)
              ),
              value: fcmProcessingMode == FCMProcessingMode.foreground? true: false,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    fcmProcessingMode = newValue? FCMProcessingMode.foreground: FCMProcessingMode.background;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            // Show text input fields when the checkbox is checked
            if (fcmProcessingMode == FCMProcessingMode.foreground) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'FCM Notif Title',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Spacer between the fields
                  Expanded(
                    child: TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        hintText: 'FCM Notif Subtitle',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              TextField(
                controller: cancelCTALabelController,
                decoration: const InputDecoration(
                  hintText: 'FCM Notif Cancel CTA Label',
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  cancelCountdownColor = getRandomHexColor();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(int.parse(cancelCountdownColor.replaceFirst('#', '0xff'))),
                shape: const RoundedRectangleBorder( borderRadius: BorderRadius.zero),
              ),
              child: const Text('Switch Color for Cancel Countdown Timer'),
            ),

            const SizedBox(height: 2),
            ElevatedButton(
              onPressed: () {
                Utils.dismissKeyboard(context);
                initSignedCallSdk(cuidController.text);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text('Register and Continue'),
            )
          ],
        ),
      ),
    );
  }

  // Initializes the Signed Call SDK
  Future<void> initSignedCallSdk(String inputCuid) async {
    if(!Utils.didSCAccountCredentialsConfigured()) {
      Utils.showSnack(context, 'Replace the AccountId and ApiKey of your Signed Call Account in the example/lib/constants.dart');
      return;
    }

    bool isDeviceVersionTargetsBelow33 =
        await Utils.isDeviceVersionTargetsBelow(13);
    if (isDeviceVersionTargetsBelow33) {
      showLoading();
    } else {
      //showLoading() only after the notification permission result is received
      //in pushPermissionResponseReceived handler
    }

    _userCuid = inputCuid;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Map<String, dynamic> callScreenBranding = {
        keyBgColor: "#000000",
        keyFontColor: "#ffffff",
        keyLogoUrl:
            "https://res.cloudinary.com/dsakrbtd6/image/upload/v1642409353/ct-logo_mkicxg.png",
        keyButtonTheme: "light",
        keyShowPoweredBySignedCall: !isPoweredByChecked,
        keyCancelCountdownColor: cancelCountdownColor
      };

      const missedCallActionsMap = {
        "1": "Call me back",
        "2": "Start Chat",
        "3": "Not Interested"
      };

      ///Common fields of Android & iOS
      final Map<String, dynamic> initProperties = {
        keyAccountId: scAccountId, //required
        keyApiKey: scApiKey, //required
        keyCuid: _userCuid, //required
        keyOverrideDefaultBranding: callScreenBranding ,//optional
        keyPromptPushPrimer: getPushPrimerJson()
      };

      ///Android only fields
      if (Platform.isAndroid) {
        initProperties[keyAllowPersistSocketConnection] = true; // required
        initProperties[keyPromptReceiverReadPhoneStatePermission] = true; // optional
        initProperties[keyMissedCallActions] = missedCallActionsMap; // optional
        initProperties[keyNotificationPermissionRequired] = notificationPermissionRequired; // optional
        initProperties[keySwipeOffBehaviourInForegroundService] = swipeOffBehaviour; // optional
        initProperties[keyFcmProcessingMode] = fcmProcessingMode; // optional

        if (fcmProcessingMode == FCMProcessingMode.foreground) {
          final Map<String, dynamic> fcmNotification = {
            keyFcmNotificationTitle: titleController.text, // Use input from the title field
            keyFcmNotificationSubtitle: subtitleController.text, // Use input from the subtitle field
            keyFcmNotificationLargeIcon: "ct_logo", // optional
            keyFcmNotificationCancelCtaLabel: cancelCTALabelController.text, // Use input from the Cancel CTA Label field
          };
          initProperties[keyFcmNotification] = fcmNotification; // optional
        }
        initProperties[keyCallScreenOnSignalling] = callScreenOnSignalling; //optional
      }

      ///iOS only fields
      if (Platform.isIOS) {
        initProperties[keyProduction] = false; //required
      }

      CleverTapSignedCallFlutter.shared.init(
          initProperties: initProperties, initHandler: _signedCallInitHandler);
    } on PlatformException {
      debugPrint('PlatformException occurs!');
    }
  }

  void _signedCallInitHandler(SignedCallError? signedCallInitError) async {
    debugPrint(
        "CleverTap:SignedCallFlutter: signedCallInitHandler called = ${signedCallInitError.toString()}");
    if (signedCallInitError == null) {
      //Initialization is successful here
      const snackBar = SnackBar(content: Text('Signed Call SDK Initialized!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      processNext();
    } else {
      //Initialization is failed here
      final errorCode = signedCallInitError.errorCode;
      final errorMessage = signedCallInitError.errorMessage;
      final errorDescription = signedCallInitError.errorDescription;

      hideLoading();
      Utils.showSnack(context, 'SC Init failed: $errorCode = $errorMessage');
    }
  }

  void processNext() {
    //save the cuid in a local session
    SharedPreferenceManager.saveLoggedInCuid(_userCuid);
    SharedPreferenceManager.savePoweredByChecked(isPoweredByChecked);
    SharedPreferenceManager.saveNotificationPermissionRequired(
        notificationPermissionRequired);
    SharedPreferenceManager.saveSwipeOffBehaviour(swipeOffBehaviour);
    SharedPreferenceManager.saveFCMProcessingMode(fcmProcessingMode);
    SharedPreferenceManager.saveFcmProcessingNotification(
      FCMProcessingNotification(title: titleController.text, subTitle: subtitleController.text, cancelCTA: cancelCTALabelController.text),
    );
    SharedPreferenceManager.saveCallScreenOnSignalling(callScreenOnSignalling);

    //Navigate the user to the Dialler Page
    Navigator.pushNamed(context, DiallerPage.routeName,
        arguments: {keyLoggedInCuid: _userCuid});
  }

  void activateHandlers() {
    _clevertapPlugin = CleverTapPlugin();
    _clevertapPlugin.setCleverTapPushPermissionResponseReceivedHandler(
        pushPermissionResponseReceived);
  }

  void initSCSDKIfCuIDSignedIn() {
    SharedPreferenceManager.getLoggedInCuid().then((loggedInCuid) {
      setState(() async {
        if (loggedInCuid != null) {
          _userCuid = loggedInCuid;
          notificationPermissionRequired =
          await SharedPreferenceManager.getNotificationPermissionRequired();
          isPoweredByChecked =
          await SharedPreferenceManager.getIsPoweredByChecked();
          swipeOffBehaviour =
          await SharedPreferenceManager.getSwipeOffBehaviour();
          callScreenOnSignalling = await SharedPreferenceManager.getCallScreenOnSignalling();

          fcmProcessingMode = await
          SharedPreferenceManager.getFCMProcessingMode();

          FCMProcessingNotification? settings = await SharedPreferenceManager.loadFcmProcessingNotification();
          if (settings != null) {
            titleController.text = settings.title;
            subtitleController.text = settings.subTitle;
            cancelCTALabelController.text = settings.cancelCTA;
          }
          initSignedCallSdk(loggedInCuid);
        }
      });
    });
  }

  void showLoading() {
    isLoadingVisible = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void hideLoading() {
    if (isLoadingVisible) {
      Navigator.pop(context);
      isLoadingVisible = false;
    }
  }

  Map<String, dynamic> getPushPrimerJson() {
    return {
      'inAppType': 'alert',
      'titleText': 'Get Notified',
      'messageText': 'Enable Notification permission',
      'followDeviceOrientation': true,
      'positiveBtnText': 'Allow',
      'negativeBtnText': 'Cancel',
      'fallbackToSettings': true
    };
  }

  String getRandomHexColor() {
    final random = Random();

    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);

    String toHex(int value) => value.toRadixString(16).padLeft(2, '0');

    return '#${toHex(red)}${toHex(green)}${toHex(blue)}';
  }
}
