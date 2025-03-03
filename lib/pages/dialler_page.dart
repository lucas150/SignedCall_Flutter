import 'dart:async';
import 'dart:collection';

import 'package:clevertap_signedcall_flutter/models/signed_call_error.dart';
import 'package:clevertap_signedcall_flutter/plugin/clevertap_signedcall_flutter.dart';
import 'package:clevertap_signedcall_flutter_example/pages/registration_page.dart';
import 'package:clevertap_signedcall_flutter_example/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../Utils.dart';
import '../constants.dart';
import '../widgets/toggle_switch_widget.dart';

class DiallerPage extends StatefulWidget {
  static const routeName = '/dialler';
  final String loggedInCuid;

  const DiallerPage({Key? key, required this.loggedInCuid}) : super(key: key);

  @override
  State<DiallerPage> createState() => _DiallerPageState();
}

class _DiallerPageState extends State<DiallerPage> {
  final receiverCuidController = TextEditingController();
  final callContextController = TextEditingController();
  final remoteCallContextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeService();
  }

  void initializeService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions:ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(300000),
        allowWakeLock: true,   // Keep CPU awake
        allowWifiLock: true,   // Prevent WiFi disconnection      
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Dialler Screen'),
            automaticallyImplyLeading: false,
          ),
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  'Welcome: ${widget.loggedInCuid}',
                  // textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: receiverCuidController,
                  decoration: const InputDecoration(
                    hintText: 'Receiver CUID',
                  ),
                ),
                TextField(
                  controller: callContextController,
                  decoration: const InputDecoration(
                    hintText: 'Context of the call',
                  ),
                ),
                TextField(
                  controller: remoteCallContextController,
                  decoration: const InputDecoration(
                    hintText: 'Remote Context of the call (Optional)',
                  ),
                ),
                const SizedBox(height: 10),
                ToggleSwitchWidget(
                  onToggleOn: () {
                    debugPrint('Toggle is ON: Starting duty');
                    FlutterForegroundTask.startService(
                      notificationTitle: 'Foreground Service is running',
                      notificationText: 'Tap to return to the app',
                      callback: startCallback
                    );
                  },
                  onToggleOff: () {
                    debugPrint('Toggle is OFF: Stopping duty');
                    FlutterForegroundTask.stopService();
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Utils.dismissKeyboard(context);
                    Utils.askMicroPhonePermission().then((value) => {
                          initiateVoIPCall(receiverCuidController.text,
                              callContextController.text, remoteCallContextController.text)
                        });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: const Text('Initiate VOIP Call'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    CleverTapSignedCallFlutter.shared.disconnectSignallingSocket();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: const Text('Disconnect Signalling Socket'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    getBackToCall();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: const Text('Get Back to Call'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    logoutSession();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          return Future.value(false);
        });
  }

  void initiateVoIPCall(String? receiverCuid, String? callContext, String? remoteCallContext) async {
    if (receiverCuid != null && callContext != null) {
      Map<String, String?> callOptions = HashMap<String, String>();

      if (remoteCallContext!.isNotEmpty) {
        // callOptions = {keyRemoteContext: remoteCallContext, keyInitiatorImage: null, keyReceiverImage: null};
        callOptions = {keyRemoteContext: remoteCallContext};
      }

      CleverTapSignedCallFlutter.shared.call(
          receiverCuid: receiverCuid,
          callContext: callContext,
          callOptions: callOptions,
          voIPCallHandler: _signedCallVoIPCallHandler);
    } else {
      Utils.showSnack(
          context, 'Both Receiver cuid and context of the call are required!');
    }
  }

  void _signedCallVoIPCallHandler(SignedCallError? signedCallVoIPError) {
    debugPrint(
        "CleverTap:SignedCallFlutter: signedCallVoIPCallHandler called = ${signedCallVoIPError.toString()}");
    if (signedCallVoIPError == null) {
      //Initialization is successful here
      Utils.showSnack(context, 'VoIP call is placed successfully!');
    } else {
      //Initialization is failed here
      final errorCode = signedCallVoIPError.errorCode;
      final errorMessage = signedCallVoIPError.errorMessage;
      final errorDescription = signedCallVoIPError.errorDescription;

      Utils.showSnack(context, 'VoIP call failed: $errorCode = $errorMessage');
    }
  }

  void logoutSession() {
    CleverTapSignedCallFlutter.shared.logout();
    SharedPreferenceManager.clearData();
    Navigator.pushNamed(context, RegistrationPage.routeName);
  }

  void getBackToCall()  {
    CleverTapSignedCallFlutter.shared.getBackToCall().then((bool result) {
      if (!result) {
        debugPrint(
            "CleverTap:SignedCallFlutter: No active call, invalid operation!");
        Utils.showToast("No active call, invalid operation to get back to call!");
      }
    });
  }
}

@pragma('vm:entry-point') // This decorator means that this function calls native code
void startCallback() {
  debugPrint("startCallback called!");
}
