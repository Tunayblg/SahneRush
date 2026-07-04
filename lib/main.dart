import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AudioService.instance.init();
  runApp(const SahneRushApp());
}

class SahneRushApp extends StatelessWidget {
  const SahneRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SahneRush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
