// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user_profile_screen.dart';
import 'utils/shared_pref_manager.dart';
import 'screens/message_screen.dart';
import 'package:home_widget/home_widget.dart';
import 'utils/widget_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefManager().init();

  try {
    await HomeWidget.initiallyLaunchedFromHomeWidget(); // Initialize the home_widget plugin
    print("HomeWidget initialized successfully.");
  } catch (e) {
    print("Error initializing homewidget: $e");
  }
    runApp(MyApp());



  // Listen for widget clicks
  HomeWidget.widgetClicked.listen((Uri? uri) {
    if (uri != null) {
      print("Widget clicked with URI: $uri");
      if (uri.toString() == 'homewidget://checkin') {
        // Perform the check-in action
        print("Triggering WidgetHelper.handleCheckIn()");
        WidgetHelper.handleCheckIn();
      }
    }
  }, onError: (error) {
    print("Error listening to widget clicks: $error");
  });
}

class MyApp extends StatelessWidget {
  final SharedPrefManager _sharedPrefManager = SharedPrefManager();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _sharedPrefManager.getUser();
    return MaterialApp(
      title: 'AfterWords App',
      home: user != null ? const UserProfileScreen() : const LoginScreen(),
      routes: {
        '/messages': (context) => const MessageScreen(),
        // Add other routes as needed
      },
    );
  }
}