// lib/utils/widget_helper.dart

import 'package:home_widget/home_widget.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'shared_pref_manager.dart';

class WidgetHelper {
  static final ApiService _apiService = ApiService();
  static final SharedPrefManager _sharedPrefManager = SharedPrefManager();

  static void handleCheckIn() async {
    print("WidgetHelper.handleCheckIn() called.");

    // Fetch the user from shared preferences
    User? user = _sharedPrefManager.getUser();
    if (user == null) {
      print("User not logged in. Cannot perform check-in.");
      // Optionally, you can trigger a notification or open the app
      return;
    }

    print("User found: ${user.username}, Current Check-In Freq: ${user.checkInFreq}, Last Login: ${user.lastLogin}");

    try {
      print("Sending check-in request for User ID: ${user.id}");
      CheckInResponse response = await _apiService.checkInUser(user.id);
      print("Check-in response received: ${response.message}, Error: ${response.error}");

      if (response.error == null || response.error!.isEmpty) {
        // Update the user data locally
        User updatedUser = User(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          username: user.username,
          email: user.email,
          checkInFreq: user.checkInFreq + 1,
          verified: user.verified,
          deceased: user.deceased,
          createdAt: user.createdAt,
          lastLogin: DateTime.now(),
          error: '',
        );

        print("Updating user data locally with Check-In Freq: ${updatedUser.checkInFreq}, Last Login: ${updatedUser.lastLogin}");

        await _sharedPrefManager.updateUser(updatedUser);
        print("User data updated in SharedPreferences.");

        // Update the widget UI
        await updateWidget();
        print("Widget UI updated with new data.");

        // Optionally, show a notification or feedback
        print('Widget Check In successful!');
      } else {
        // Handle error
        print('Check In failed: ${response.error}');
      }
    } catch (e) {
      // Handle exception
      print('Error during Check In: $e');
    }
  }

  static Future<void> updateWidget() async {
    print("WidgetHelper.updateWidget() called.");

    User? user = _sharedPrefManager.getUser();
    if (user == null) {
      print("No user data found. Cannot update widget.");
      return;
    }

    Map<String, dynamic> data = {
      'checkInFreq': user.checkInFreq.toString(),
      'lastLogin': user.lastLogin?.toIso8601String() ?? '',
    };

    print("Saving widget data: Check-In Freq = ${data['checkInFreq']}, Last Login = ${data['lastLogin']}");

    try {
      await HomeWidget.saveWidgetData<String>('checkInFreq', data['checkInFreq']);
      await HomeWidget.saveWidgetData<String>('lastLogin', data['lastLogin']);
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider',
        iOSName: 'HomeWidget', // If targeting iOS
      );
      print("Widget data saved and update triggered.");
    } catch (e) {
      print("Error updating widget: $e");
    }
  }
}
