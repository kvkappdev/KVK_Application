import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialise() async {
    _fcm.configure(
        //Foreground
        onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    },
        //App is closed
        onLaunch: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    },
        //Background state
        onResume: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    });
  }

  Future subscribeToAnnouncements() async {
      await _fcm.subscribeToTopic("announcements");
  }
   Future unSubscribeToAnnouncements() async {
      await _fcm.unsubscribeFromTopic("announcements");
  }
}
