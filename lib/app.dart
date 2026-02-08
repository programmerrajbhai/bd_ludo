import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

class BdLudoApp extends StatelessWidget {
  const BdLudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangladeshi Ludo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
