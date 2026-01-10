// ignore_for_file: unused_import, unnecessary_const, avoid_print

import 'dart:convert'; // added for jsonEncode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/splash_screen.dart';
import 'pages/homepage.dart';
import 'pages/login.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'package:project/providers/orders_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/faq_list_page.dart';
import 'services/connectivity_service.dart';
import 'services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // added
import 'package:http/http.dart' as http; // added

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background FCM message received: ${message.messageId}');
}

Future<void> saveAdminFCMToken(String userId) async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken(); // get FCM token

  if (token != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fcm_token', token);

    // Send token to backend so Laravel can notify this admin
    final url = Uri.parse('http://10.0.2.2:8000/api/save-fcm-token');
    await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${prefs.getString('token')}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"fcm_token": token}),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Foreground messages (for admin notifications)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground FCM message received: ${message.notification?.title}');
    if (message.notification != null) {
      // Optionally: show a SnackBar or alert
      // Note: context not available here, handle in admin dashboard page
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked: ${message.data}');
    // Optionally navigate to order details page
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        Provider(create: (_) => ConnectivityService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => Login(),
        '/faq': (context) => const FAQListPage(),
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF7dadc4),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF7dadc4), size: 30),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF80CBC4),
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        cardColor: const Color(0xFF2C2C3C),
        dividerColor: Colors.grey.shade700,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70, fontFamily: 'MontserratRegular'),
          bodyMedium: TextStyle(color: Colors.white70, fontFamily: 'MontserratRegular'),
          titleLarge: TextStyle(color: Colors.white, fontFamily: 'MontserratRegular'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C3C),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF80CBC4), size: 30),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF80CBC4),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C2C3C),
          selectedItemColor: Color(0xFF80CBC4),
          unselectedItemColor: Colors.white54,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF323244),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Splashscreen();
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomePage();
          } else {
            return const Splashscreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}
