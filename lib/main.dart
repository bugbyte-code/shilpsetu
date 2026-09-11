import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dzyetjzcolcxzottvpmg.supabase.co',
    publishableKey: 'sb_publishable_GpUA9IL-nc2H2KOBdo8HEQ_FBUUfGKC',
  );

  runApp(const ShilpSetuApp());
}

class ShilpSetuApp extends StatelessWidget {
  const ShilpSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShilpSetu',

      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
        ),
      ),

      home: const WelcomeScreen(),
    );
  }
}