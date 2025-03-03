import 'package:clevertap_signedcall_flutter_example/constants.dart';
import 'package:clevertap_signedcall_flutter_example/pages/dialler_page.dart';
import 'package:clevertap_signedcall_flutter_example/pages/registration_page.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == "/") {
      return MaterialPageRoute(
          builder: (context) =>
              const RegistrationPage(title: "Signed Call Sample"));
    } else if (settings.name == DiallerPage.routeName) {
      Map arguments = settings.arguments as Map;
      return MaterialPageRoute(
          builder: (context) =>
              DiallerPage(loggedInCuid: arguments[keyLoggedInCuid]));
    } else {
      return MaterialPageRoute(
          builder: (context) =>
              const RegistrationPage(title: "Signed Call Sample"));
    }
  }
}
