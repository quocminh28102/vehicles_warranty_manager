import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vehicles_warranty_manager/l10n/app_localizations.dart';

import 'auth/auth_gate.dart';

class VehiclesWarrantyManagerApp extends StatelessWidget {
  const VehiclesWarrantyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VehiclesWarrantyManager',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5A6A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        cardTheme: const CardThemeData(
          elevation: 0.5,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
