import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fcm.requestPermission();

    String? token = await _fcm.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    FirebaseMessaging.onMessage.listen((message) {
      print("Notification received: ${message.notification?.title}");
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');

    if (authToken == null) return;

    await http.post(
      Uri.parse('http://10.0.2.2:8000/api/save-fcm-token'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: '{"fcm_token": "$token"}',
    );
  }
}
