import 'package:emotion_app/Pages/devMenuPage.dart';
import 'package:emotion_app/auth/auth_gate.dart';
import 'package:emotion_app/services/mock_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la locale française pour intl (utilisé par DateFormat
  // dans le calendrier, le questionnaire, etc.)
  await initializeDateFormatting('fr_FR', null);

  await Supabase.initialize(
    url: 'https://mftyadvkuddrtfrodgmd.supabase.co',
    anonKey: 'sb_publishable_5DHv6pItqNPUqQr2kQjRaA_UEEVzx_L',
  );

  // Étape 1 du cahier des charges : remplir l'app de logs factices pour
  // que le calendrier ne soit pas vide tant que Supabase n'est pas branché.
  // À l'étape 4, on remplacera ces données par un select() sur daily_logs.
  MockDataService.seed();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Harmony',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB79CED),
        scaffoldBackgroundColor: const Color(0xFFFCF5FF),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB79CED),
          primary: const Color(0xFFB79CED),
          secondary: const Color(0xFF4C4A73),
        ),
        useMaterial3: true,
      ),
      // Localisations Flutter (français) — pour les widgets natifs
      // (DatePicker, etc.). table_calendar reçoit aussi locale: 'fr_FR'.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),

      // ============================================================
      // 🛠 MODE DÉVELOPPEMENT
      // Pour tester tous les écrans sans passer par Supabase, on
      // démarre sur le DevMenuPage.
      //
      // Quand le projet Supabase est de nouveau actif, REMPLACER
      //     home: const DevMenuPage(),
      // par
      //     home: const AuthGate(),
      // pour revenir au flux normal (login → profil → accueil).
      //
      // Ne pas oublier d'enlever cet import quand on revient en prod :
      //     import 'package:emotion_app/Pages/devMenuPage.dart';
      // ============================================================
      home: const DevMenuPage(),
      // home: const AuthGate(),
    );
  }
}
