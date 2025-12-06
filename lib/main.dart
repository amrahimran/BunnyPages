// ignore_for_file: unused_import, unnecessary_const

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
import 'services/connectivity_service.dart'; // <-- NEW IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        Provider<ConnectivityService>( // <-- NEW PROVIDER
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
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
        '/faq': (context) => const FAQListPage(), // <-- NEW ROUTE
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
        primaryColor: const Color(0xFF80CBC4),           // Soft teal accent (buttons, highlights)
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Dark but soft background
        cardColor: const Color(0xFF2C2C3C),             // For cards/containers
        dividerColor: Colors.grey.shade700,             // Divider lines
        textTheme: const TextTheme(
          bodyLarge: const TextStyle(color: Colors.white70, fontFamily: 'MontserratRegular'),
          bodyMedium: const TextStyle(color: Colors.white70, fontFamily: 'MontserratRegular'),
          titleLarge: const TextStyle(color: Colors.white, fontFamily: 'MontserratRegular'),

        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C3C),           // Dark appbar
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
