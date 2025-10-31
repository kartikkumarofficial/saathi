import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saathi/presentation/screens/splash_screen.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/bindings.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await Supabase.initialize(
    url: constants.supabaseUrl,
    anonKey: constants.supabaseKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _tealGreen = Color(0xFF7AB7A7);
  static const Color _darkText = Color(0xFF4A4E6C);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Saathi',
      initialBinding: InitialBinding(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFfdfaf6),
        fontFamily: GoogleFonts.nunito().fontFamily,
        cardColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: _tealGreen,
          unselectedItemColor: Colors.grey,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _tealGreen,
          primary: _tealGreen,
          onSurface: _darkText,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}