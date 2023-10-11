import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService{
  static NotificationService instance = NotificationService();

  FirebaseMessaging? _firebaseMessaging;

  NotificationService(){
    // create an instance of Firebase Messaging
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  // function to initialize notification
  Future<void> initNotification() async{
    // Request permission from user (will prompt out to ask user)
    await _firebaseMessaging?.requestPermission();

    // Fetch the FCM token for this device
    final fcmToken = await _firebaseMessaging?.getToken();

    // print the token (normally you would send this to your server)
    print("Token : ${fcmToken}");
  }


  // function to handle received messages

  // function to initialize foreground and background settings
}