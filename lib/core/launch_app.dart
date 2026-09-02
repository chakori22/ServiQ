import 'package:flutter/material.dart';
import 'package:local_markerplace/core/serviq_app.dart';
import 'package:local_markerplace/splash/splash_screen.dart';

class LaunchApp extends StatefulWidget {
  const LaunchApp({super.key});

  @override
  State<LaunchApp> createState() => _LaunchAppState();
}

class _LaunchAppState extends State<LaunchApp> {
  static const _minimumSplashDuration = Duration(seconds: 3);

  late final Future<Widget> _appFuture;

  @override
  void initState() {
    super.initState();
    _appFuture = _buildApp();
  }

  Future<Widget> _buildApp() async {
    final serviqApp = appBuilder('http://13.207.78.186:8080');
    await Future.wait([
      serviqApp,
      Future<void>.delayed(_minimumSplashDuration),
    ]);
    return serviqApp;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _appFuture,
      builder: (context, AsyncSnapshot<Widget> childWidget) {
        final data = childWidget.data;
        if (childWidget.connectionState == ConnectionState.done &&
            data != null) {
          return data;
        } else if (childWidget.hasError) {
          return SplashScreen();
        } else {
          final error = childWidget.error;
          if (error != null) {
            return SplashScreen();
          }
        }

        return SplashScreen();
      },
    );
  }
}
