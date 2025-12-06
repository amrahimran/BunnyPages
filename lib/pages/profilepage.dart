// ignore_for_file: use_build_context_synchronously, unused_local_variable, sort_child_properties_last

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/components/custombar.dart';
import 'package:project/pages/splash_screen.dart';
import 'package:project/pages/wishlist.dart';
import 'package:project/services/connectivity_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:quickalert/quickalert.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMsg = '';

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
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMsg = 'Not logged in (no token).';
        });
        return;
      }

      final url = Uri.parse('$baseUrl/api/user');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        Map<String, dynamic>? user;
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('user') && jsonData['user'] is Map) {
            user = Map<String, dynamic>.from(jsonData['user']);
          } else if (jsonData.containsKey('data') && jsonData['data'] is Map) {
            user = Map<String, dynamic>.from(jsonData['data']);
          } else {
            user = Map<String, dynamic>.from(jsonData);
          }
        }

        setState(() {
          userData = user;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'Failed to fetch user (status ${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'Error fetching user: $e';
      });
    }
  }

  Future<void> updateUserData(String name, String email, String? password) async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('$baseUrl/api/user/update');

      Map<String, dynamic> body = {
        'name': name,
        'email': email,
      };
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Profile updated successfully!",
        );
        fetchUserData();
      } else {
        final data = json.decode(response.body);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: data['message'] ?? 'Failed to update profile.',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Error updating profile: $e',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userData?['name'] ?? '');
    final emailController = TextEditingController(text: userData?['email'] ?? '');
    final passwordController = TextEditingController();

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF7dadc4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              String email = emailController.text.trim();
              String password = passwordController.text.trim();

              if (name.isEmpty) {
                QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Name cannot be empty.');
                return;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Enter a valid email.');
                return;
              }
              if (password.isNotEmpty && password.length < 6) {
                QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Password must be at least 6 characters.');
                return;
              }

              Navigator.pop(context);
              updateUserData(name, email, password.isEmpty ? null : password);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7dadc4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomBar(),
      bottomNavigationBar: const Bottombar(selectedIndex: 3),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(errorMsg, style: const TextStyle(color: Colors.red)),
                  ),
                )
              : Column(
                  children: [
                    const ConnectivityBanner(),

                    // Scrollable profile content below
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAvatarSection(isDark),
                            const SizedBox(height: 25),
                            _buildInfoContainer(isDark),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _showEditProfileDialog,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7dadc4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildFavoritesRow(),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/faq'),
                              child: const Text("FAQs"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7dadc4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildLogoutRow(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    final avatarUrl = userData?['profile_photo_url'];
    final displayName = userData?['name'] ?? 'User Name';

    return Column(
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
          backgroundImage: avatarUrl != null && avatarUrl.toString().isNotEmpty
              ? NetworkImage(avatarUrl)
              : const AssetImage('assets/images/profilepic.webp') as ImageProvider,
        ),
        const SizedBox(height: 10),
        Text(
          displayName,
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'MontserratSemibold',
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContainer(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildInfoColumn(isDark),
    );
  }

  Widget _buildInfoColumn(bool isDark) {
    final email = userData?['email'] ?? 'Not available';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoText("Email", email, isDark),
      ],
    );
  }

  Widget _buildInfoText(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'MontserratRegular',
            color: isDark ? Colors.white70 : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'MontserratRegular',
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesRow() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WishlistPage()),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("Favorites", style: TextStyle(fontSize: 18, fontFamily: 'MontserratRegular')),
          SizedBox(width: 10),
          Icon(Icons.favorite, color: Color(0xFF7dadc4), size: 24),
        ],
      ),
    );
  }

  Widget _buildLogoutRow() {
    return Row(
      children: [
        const Icon(Icons.logout, color: Colors.redAccent),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            await prefs.remove('token');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Splashscreen()),
            );
          },
          child: const Text(
            "Logout",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
