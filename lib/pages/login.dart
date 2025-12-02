// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'signup.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:quickalert/quickalert.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      if (Platform.isIOS) return 'http://localhost:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  /// If token exists → user already logged in
  Future<void> _checkExistingToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  /// LOGIN FUNCTION (UPDATED FOR LARAVEL SANCTUM)
  Future<void> login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      var url = Uri.parse('$baseUrl/api/login');

      var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      var data = jsonDecode(response.body);

      // SUCCESS → TOKEN RECEIVED
      if (response.statusCode == 200 && data['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Login Successful!",
          customAsset: 'assets/images/login.webp',
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });

        return;
      }

      // CREDENTIALS WRONG (422)
      if (response.statusCode == 422) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: data['message'] ?? "Invalid credentials",
          customAsset: 'assets/images/failed.webp',
        );
        return;
      }

      // OTHER ERRORS
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: data['message'] ?? "Login failed",
        customAsset: 'assets/images/failed.webp',
      );
    } catch (e) {
      setState(() => isLoading = false);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Error: $e",
        customAsset: 'assets/images/failed.webp',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFF7dadc4),
                  fontSize: 45,
                  fontFamily: 'Chewy',
                ),
              ),
              const SizedBox(height: 16),

              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains("@")) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // PASSWORD
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter password' : null,
              ),

              const SizedBox(height: 40),

              // LOGIN BUTTON
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7dadc4),
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      child: const SizedBox(
                        width: 250,
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'MontserratRegular',
                            ),
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              // SIGNUP LINK
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Signup()),
                  );
                },
                child: const Text(
                  "Don't have an account yet? Click here to sign up.",
                  style: TextStyle(
                    color: Color(0xFF7dadc4),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
