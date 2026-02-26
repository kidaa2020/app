import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/bottom_nav_shell.dart';

class HealthBuddyApp extends StatelessWidget {
  const HealthBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BottomNavShell(),
    );
  }
}
