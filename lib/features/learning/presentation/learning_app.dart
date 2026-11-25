import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Learnspace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8F5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFED713E),
            primary: const Color(0xFFED713E),
            surface: const Color(0xFFFFFFFF),
          ),
          fontFamily: 'sans-serif',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F8F5),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const HomeScreen(),
      );
}
