// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:project/pages/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  // SAME baseUrl logic as Login page
  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    if (Platform.isIOS) return 'http://localhost:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<void> registerUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      var url = Uri.parse('$baseUrl/api/register');
      var response = await http.post(url, body: {
        'name': _usernameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text.trim(),
        'password_confirmation': _confirmPasswordCtrl.text.trim(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Registration Successful!",
          customAsset: "assets/images/login.webp",
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        });
      } else {
        var data = json.decode(response.body);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: data['message'] ?? "Registration failed",
          customAsset: "assets/images/failed.webp",
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Could not connect to server.\n$e",
        customAsset: "assets/images/failed.webp",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: Color(0xFF7dadc4),
                  fontFamily: 'Chewy',
                  fontSize: 45,
                ),
              ),
              const SizedBox(height: 16),

              // USERNAME
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Username is required' : null,
              ),
              const SizedBox(height: 16),

              // EMAIL
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // PASSWORD
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password';
                  }
                  if (value != _passwordCtrl.text) {
                    return "Passwords don't match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: registerUser,
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
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'MontserratRegular',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
