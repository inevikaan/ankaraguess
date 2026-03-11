import 'package:flutter/material.dart';

import 'game/ui/home_screen.dart';
import 'theme/app_theme.dart';

class AnkaraGuessApp extends StatelessWidget {
  const AnkaraGuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkaraGuess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
