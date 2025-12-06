// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_service.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  _ConnectivityBannerState createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    final service = Provider.of<ConnectivityService>(context, listen: false);

    // Listen to connectivity changes
    service.connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });

    // Initial check
    _initialCheck();
  }

  Future<void> _initialCheck() async {
    try {
      final service = Provider.of<ConnectivityService>(context, listen: false);
      ConnectivityResult result = await service.checkConnectivity();
      if (mounted) {
        setState(() {
          _isOnline = result != ConnectivityResult.none;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isOnline
        ? const SizedBox.shrink()
        : Container(
            color: Colors.red,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'No Internet Connection',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
  }
}
